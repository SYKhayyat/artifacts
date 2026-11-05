#!/usr/bin/env python3
"""Convert lisp.org into the Typst source tree for the PDF build."""

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
if os.path.exists(os.path.join(HERE, "lisp.org")):
    # Run from the book's own directory: the source sits beside the script.
    SRC = os.path.join(HERE, "lisp.org")
    OUT = HERE
else:
    SRC = os.path.join(HERE, "..", "lisp.org")
    OUT = os.path.join(HERE, "..", "artifacts", "thinking-in-common-lisp")

SPECIAL = set("\\#*_`$@<>[]~/")

H1_FRONT = "How to Use This Guide"


def esc(text):
    return "".join("\\" + c if c in SPECIAL else c for c in text)


# A key sequence -- C-c C-c, M-x, SPC f e d -- is set as one unbreakable
# unit: a line ending between "C-" and "c" reads as a typo.
KEY_TOKEN = r"(?:[CMS]-[A-Za-z0-9<>/',.\-]+|SPC|TAB|RET|ESC|DEL)"
KEY_RE = re.compile(r"^" + KEY_TOKEN + r"(?: " + KEY_TOKEN + r")*$")


def raw_inline(code):
    code = code.strip()
    n = 1
    while "`" * n in code:
        n += 1
    t = "`" * n
    if code.startswith("`") or code.endswith("`"):
        return t + " " + code + " " + t
    return t + code + t


# Org's own emphasis rules: a marker opens only at a boundary (start of the
# paragraph, or after whitespace or opening punctuation) and closes only where
# it is followed by the end of the paragraph or by punctuation/whitespace. The
# content may not begin or end with whitespace, and for "=" and "~" it may not
# contain the marker itself.
PRE = set("- \t('\"{<[")
POST = set("- \t.,:!?;'\")}\\[<>/=")
MARKERS = {"=": "code", "~": "code", "*": "strong", "/": "emph"}

# The numeric-equality function is a code span whose content is a bare "=",
# written "===" in the source; no boundary rule can see it.
BARE_EQ_RE = re.compile(r"(?<![\w=])===(?![\w=])")
# "=load=ed" -- a code span closed directly against a following word. Org
# itself would not read this as a span, but the intent is plain.
GLUED_CODE_RE = re.compile(r"(?<![\w=])=([A-Za-z0-9*:+/#<>_.-]{1,40})=(?=[A-Za-z])")


def plausible_code(code):
    """Reject spans that run across a sentence boundary, or that are mostly
    spaces between words: both are a sign of an unmatched delimiter rather
    than a code span."""
    # ". " followed by a capitalised word is a sentence boundary; ". " in a
    # dotted pair -- (APPLE . RED) -- is not.
    if re.search(r"\.\s+[A-Z][a-z]", code):
        return False
    if code != code.strip() and code.count(" ") >= 2:
        return False
    if ": " in code and code.count(" ") > 8:
        return False
    return True


def kind_is_code(kind):
    return kind == "code"


def parens_balanced(s):
    depth = 0
    for c in s:
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


def drop_stray_delimiters(text):
    """Remove markers that never found a partner.

    A span whose delimiters do not pair up has already been passed over by the
    scanner; what is left is a character that would print as itself. Dropping
    it loses emphasis at worst, where keeping it prints a stray /, ~ or = in
    the middle of a sentence.
    """
    out = []
    n = len(text)
    for i, ch in enumerate(text):
        prev = text[i - 1] if i else None
        nxt = text[i + 1] if i + 1 < n else None
        at_open = (prev is None or prev in PRE) and nxt is not None and not nxt.isspace()
        at_close = (nxt is None or nxt in POST) and prev is not None and not prev.isspace()
        if ch == "~" and (at_open or at_close):
            continue
        if ch == "/" and at_open and nxt is not None and nxt.isalpha():
            continue
        if ch == "=" and (at_open or at_close):
            continue
        out.append(ch)
    return "".join(out)


def inner_marker_ok(body, marker):
    """A marker inside a span is legitimate only where it stands on its own --
    =(= 1 2)=, =for var = start then next=. Glued to a word, it means the span
    ran away from its real delimiters."""
    if " " in body:
        p = body.find(marker)
    else:
        p = -1
    while p >= 0:
        before = body[p - 1] if p else " "
        after = body[p + 1] if p + 1 < len(body) else " "
        if before not in " ([{" and after not in " )]}":
            return False
        p = body.find(marker, p + 1)
    return True


# Typst swallows a semicolon written directly after a content block --
# #strong[habit]; loses the punctuation -- so the span is followed by a
# semicolon of its own and the real one is consumed. This flag says a
# semicolon is owed.
EAT_SEMI = [False]


def scan_markup(text, keep):
    """Replace Org emphasis spans with placeholders, following Org's rules.

    A single left-to-right pass, so that "=a=, =b= and =c=" is three spans and
    an unmatched delimiter is left alone instead of swallowing its neighbours.
    """
    out = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        if ch in MARKERS:
            prev = text[i - 1] if i else None
            nxt = text[i + 1] if i + 1 < n else None
            opens = prev is None or prev in PRE or (ch == "=" and prev == "/")
            if opens and nxt is not None and not nxt.isspace():
                close = -1
                j = i + 1
                while True:
                    k = text.find(ch, j)
                    if k < 0 or k <= i + 1:
                        break
                    before = text[k - 1]
                    after = text[k + 1] if k + 1 < n else None
                    # A body ending in an opening bracket means the
                    # "delimiter" was really the first character of code such
                    # as =(= a b)=: keep looking for the true close.
                    # A well-formed Lisp span has balanced parentheses; an
                    # unbalanced body means this is an "=" inside the code,
                    # as in =(string= s "")=, not the closing delimiter.
                    if (after is None or after in POST) and not before.isspace() \
                       and not (kind_is_code(MARKERS[ch]) and before == "(") \
                       and (not kind_is_code(MARKERS[ch]) or
                            parens_balanced(text[i + 1:k])):
                        close = k
                        break
                    j = k + 1
                if close > 0:
                    # The source writes a trailing marker twice when the code
                    # itself ends in one -- =string== for the function string=.
                    while close + 1 < n and text[close + 1] == ch and \
                          kind_is_code(MARKERS[ch]):
                        close += 1
                    body = text[i + 1:close]
                    frag = keep(MARKERS[ch], body, ch,
                                text[close + 1] if close + 1 < n else "")
                    if frag is not None:
                        out.append(frag)
                        i = close + 1 + (1 if EAT_SEMI[0] else 0)
                        EAT_SEMI[0] = False
                        continue
        out.append(ch)
        i += 1
    return "".join(out)


CODE_RUN = set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
               "*:+/#<>_.'$?-@!&")


def run_start(text, k):
    """Start of the code-shaped run that ends just before position K."""
    j = k - 1
    if j < 0:
        return None
    if text[j] == ")":
        depth = 0
        while j >= 0:
            if text[j] == ")":
                depth += 1
            elif text[j] == "(":
                depth -= 1
                if depth == 0:
                    return j if k - j > 3 else None
            j -= 1
        return None
    start = j
    while start >= 0 and text[start] in CODE_RUN:
        start -= 1
    start += 1
    return start if k - start >= 1 else None


def repair_bare_marker(text, make_frag):
    out = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        if ch == "=":
            after = text[i + 1] if i + 1 < n else None
            if after is None or after in POST:
                start = run_start(text, i)
                if start is not None and text[start] not in "/~" \
                   and plausible_code(text[start:i]):
                    # The run's characters are already in OUT; replace them
                    # with the code fragment as one piece.
                    del out[len(out) - (i - start):]
                    out.append(make_frag(text[start:i]))
                    i += 1
                    continue
        out.append(ch)
        i += 1
    return "".join(out)


def sub_plausible(pattern, text, make_frag):
    """Substitute matches of PATTERN, skipping implausible ones and
    leaving the original text in place for those."""
    out = []
    pos = 0
    scan = 0
    while True:
        m = pattern.search(text, scan)
        if not m:
            break
        if not plausible_code(m.group(1)):
            # An unmatched delimiter: step past this candidate rather than
            # skipping the whole region it happens to span.
            scan = m.start() + 1
            continue
        out.append(text[pos:m.start()])
        out.append(make_frag(m))
        pos = m.end()
        scan = pos
    out.append(text[pos:])
    return "".join(out)


SUSPECT = []
CUR_LINE = [0]


def inline(text, store=None):
    # An emphasised run can hold code spans of its own; those are converted by
    # a recursive call that shares this store, so the placeholders all number
    # the same table and nothing is left dangling.
    if store is None:
        store = []

    def keep(frag, code=None):
        if code is not None and len(code.split()) > 6:
            SUSPECT.append((CUR_LINE[0], code))
        store.append(frag)
        return "\x00%d\x00" % (len(store) - 1)

    def code_keep(content):
        frag = raw_inline(content)
        if KEY_RE.match(content.strip()):
            frag = "#box[%s]" % frag
        return keep(frag, content)

    def markup_keep(kind, body, marker, after=""):
        if not plausible_code(body) or len(body) > 120:
            return None
        if kind == "code":
            # A trailing marker is allowed: the scanner folds "=string=="
            # (the function string=) into one span.
            inner = body.rstrip(marker)
            if marker in inner and not inner_marker_ok(inner, marker):
                return None
            return code_keep(body)
        # Emphasis can hold code spans of its own, so convert the inside too.
        tag = "#strong" if kind == "strong" else "#emph"
        frag = "%s[%s]" % (tag, inline(body, store))
        if after == ";":
            frag += '#";"'
            EAT_SEMI[0] = True
        return keep(frag)

    text = BARE_EQ_RE.sub(lambda m: code_keep("="), text)
    text = sub_plausible(GLUED_CODE_RE, text, lambda m: code_keep(m.group(1)))
    text = scan_markup(text, markup_keep)

    # Some lines in the source lost the opening delimiter of a code span and
    # left the closing one behind: "main= exits 1" for "=main= exits 1". Where
    # a closing marker follows a code-shaped run and sits at a sentence
    # boundary, read the run as code and drop the marker.
    text = repair_bare_marker(text, lambda body: keep(raw_inline(body)))
    text = drop_stray_delimiters(text)
    out = esc(text)
    # Fragments can nest (a code span inside an emphasised run, say), and a
    # fragment may itself contain a placeholder for one already substituted,
    # so keep substituting until nothing is left.
    for _ in range(len(store) + 1):
        if "\x00" not in out:
            break
        for i, frag in enumerate(store):
            out = out.replace("\x00%d\x00" % i, frag)
    if "\x00" in out:
        raise AssertionError("unsubstituted placeholder at line %d: %r" % (CUR_LINE[0], out[:120]))
    return out


class Node:
    __slots__ = ("level", "title", "items")

    def __init__(self, level, title):
        self.level = level
        self.title = title
        self.items = []


LIST_RE = re.compile(r"^(\s*)([-+]|\d+\.)\s+(\S.*)$")


def dedent_blocks(lines):
    """Pull an indented src block (one written inside a list item) back to the
    left margin, where the page sets it. Without this the block's marker lines
    read as list continuation text and the code collapses into a paragraph."""
    out = []
    i = 0
    n = len(lines)
    while i < n:
        m = re.match(r"^(\s+)#\+begin_src", lines[i])
        if not m:
            out.append(lines[i])
            i += 1
            continue
        indent = len(m.group(1))
        out.append(lines[i][indent:])
        i += 1
        while i < n:
            line = lines[i]
            if line.strip().startswith("#+end_src"):
                out.append(line.strip())
                i += 1
                break
            out.append(line[indent:] if not line[:indent].strip() else line.lstrip())
            i += 1
    return out


def parse(lines):
    root = Node(0, None)
    stack = [root]
    i = 0
    n = len(lines)
    para = []

    def flush():
        if para:
            stack[-1].items.append((
                "p",
                para[0][0],
                " ".join(t.strip() for _, t in para),
            ))
            para.clear()

    while i < n:
        line = lines[i]
        if line.startswith("#+TITLE") or line.startswith("#+SUBTITLE") or \
           line.startswith("#+STARTUP") or line.startswith("#+OPTIONS") or \
           line.startswith("#+PROPERTY"):
            i += 1
            continue
        m = re.match(r"^(\*+) (.*)$", line)
        if m:
            flush()
            lvl = len(m.group(1))
            node = Node(lvl, m.group(2).strip())
            while stack[-1].level >= lvl:
                stack.pop()
            stack[-1].items.append(node)
            stack.append(node)
            i += 1
            continue
        if line.startswith("#+begin_src"):
            flush()
            parts = line.split()
            lang = parts[1] if len(parts) > 1 else ""
            j = i + 1
            body = []
            while not lines[j].startswith("#+end_src"):
                body.append(lines[j])
                j += 1
            stack[-1].items.append(("src", lang, body))
            i = j + 1
            continue
        if line.startswith("#+begin_example"):
            flush()
            j = i + 1
            body = []
            while not lines[j].startswith("#+end_example"):
                b = lines[j]
                if b.startswith(","):
                    b = b[1:]
                body.append(b)
                j += 1
            stack[-1].items.append(("ex", body))
            i = j + 1
            continue
        if line.startswith("#+RESULTS:"):
            flush()
            j = i + 1
            body = []
            while j < n and lines[j].startswith(":"):
                body.append(lines[j][2:] if lines[j].startswith(": ") else lines[j][1:])
                j += 1
            stack[-1].items.append(("ex", body))
            i = j
            continue
        if line.startswith(": "):
            flush()
            body = []
            while i < n and lines[i].startswith(":"):
                body.append(lines[i][2:] if lines[i].startswith(": ") else lines[i][1:])
                i += 1
            stack[-1].items.append(("ex", body))
            continue
        if line.startswith("|"):
            flush()
            rows = []
            while i < n and lines[i].startswith("|"):
                rows.append(lines[i])
                i += 1
            stack[-1].items.append(("table", rows))
            continue
        if not line.strip():
            flush()
            i += 1
            continue
        lm = LIST_RE.match(line)
        if lm and not para:
            flush()
            items = []
            indent = len(lm.group(1))
            while i < n:
                l2 = lines[i]
                m2 = LIST_RE.match(l2)
                if m2:
                    items.append((len(m2.group(1)), m2.group(2), m2.group(3)))
                    i += 1
                    continue
                if not l2.strip():
                    break
                if re.match(r"^(\*+) ", l2) or l2.startswith("#+"):
                    break
                # continuation of the previous item
                ind, mark, txt = items[-1]
                items[-1] = (ind, mark, txt + " " + l2.strip())
                i += 1
            stack[-1].items.append(("list", items))
            continue
        para.append((i + 1, line))
        i += 1
    flush()
    return root


# ---------------- emission ----------------

def fence(lines, lang=""):
    n = 3
    while any(l.strip() == "`" * n for l in lines):
        n += 1
    t = "`" * n
    # Blocks with an over-long line are set a size smaller rather than
    # running into the margin; the -s suffix is what main.typ keys on.
    tag = lang or "text"
    if any(len(l) > 84 for l in lines):
        tag += "-s"
    return [t + tag] + lines + [t, ""]


def emit_table(rows, out):
    def cells(row):
        row = row.strip()
        if row.startswith("|"):
            row = row[1:]
        if row.endswith("|"):
            row = row[:-1]
        return [c.strip() for c in row.split("|")]

    body = []
    header = cells(rows[0])
    for r in rows[1:]:
        if re.fullmatch(r"\|[\-+|: ]+\|?", r.strip()):
            continue
        body.append(cells(r))
    def    plain(cell):
        """The cell's text with the emphasis and code markers taken out."""
        return re.sub(r"[=~*/`]", "", cell).strip()

    ncols = len(header)
    widths = []
    for c in range(ncols):
        best = 6
        for cell in [r[c] for r in [header] + body if c < len(r)]:
            best = max(best, len(plain(cell)))
        widths.append(best)
    # A column must be at least as wide as its longest unbreakable word, or
    # the word hyphenates -- a header reading "Re-sult" is the visible case.
    # Widths are handed out in proportion to content, then a column that
    # comes out too narrow is topped up from the widest one.
    CHAR_PT, PAD_PT, FR_PT = 5.6, 13.0, 55.8
    floors = []
    for c in range(ncols):
        cells = [plain(r[c]) for r in [header] + body if c < len(r)]
        word = max(len(header[c]) if c < len(header) else 0,
                   max([len(w) for w in cells if " " not in w] + [0]))
        # A short cell -- (3 2 1) in a Result column -- should not be broken
        # across lines either: ask for the width of the widest one.
        if widths[c] <= 16:
            word = max(word, widths[c])
        floors.append((word * CHAR_PT + PAD_PT) / FR_PT)
    total = sum(widths)
    shares = [8.0 * w / total for w in widths]
    for _ in range(ncols):
        poor = [c for c in range(ncols) if shares[c] < floors[c]]
        if not poor:
            break
        rich = max(range(ncols), key=lambda c: shares[c] - floors[c])
        c = poor[0]
        if rich == c or shares[rich] - floors[rich] <= 0:
            break
        take = min(floors[c] - shares[c], shares[rich] - floors[rich])
        shares[c] += take
        shares[rich] -= take
    cols = ", ".join("%.1ffr" % max(0.55, s) for s in shares)
    # Justified text in a narrow column puts rivers of space between the
    # words of a short cell; tables read better ragged right.
    out.append("#[")
    out.append("  #set par(justify: false)")
    out.append("  #table(")
    out.append("    columns: (%s)," % cols)
    out.append("    inset: (x: 6pt, y: 4pt),")
    out.append("    stroke: 0.3pt + luma(200),")
    out.append("    align: left,")
    out.append("    table.header(%s)," % ", ".join("[%s]" % inline(c) for c in header))
    for r in body:
        cellsr = [inline(c) for c in r] + [""] * (ncols - len(r))
        out.append("    " + ", ".join("[%s]" % c for c in cellsr[:ncols]) + ",")
    out.append("  )")
    out.append("]")
    out.append("")


def emit_items(items, out):
    for it in items:
        kind = it[0]
        if kind == "p":
            CUR_LINE[0] = it[1]
            out.append(inline(it[2]))
            out.append("")
        elif kind == "src":
            out.extend(fence(it[2], it[1]))
        elif kind == "ex":
            out.extend(fence(it[1]))
        elif kind == "list":
            rows = it[1]
            # A numbered list interrupted by a code block resumes at the number
            # it left off, so keep its own counter instead of restarting at 1.
            first = rows[0][1]
            flat = all(r[0] == rows[0][0] for r in rows)
            if first[0].isdigit() and int(first.rstrip(".")) > 1 and flat:
                start = int(first.rstrip("."))
                body = ", ".join("[%s]" % inline(r[2]) for r in rows)
                out.append("#enum(start: %d, %s)" % (start, body))
                out.append("")
                continue
            for indent, mark, txt in rows:
                pad = "  " * (indent // 2)
                marker = "+" if mark[0].isdigit() else "-"
                out.append("%s%s %s" % (pad, marker, inline(txt)))
            out.append("")
        elif kind == "table":
            emit_table(it[1], out)
        else:  # pragma: no cover
            raise AssertionError(kind)


EX_RE = re.compile(r"^Exercise (\d+\.\d+)(\s*\(project\))?$")


def emit_node(node, out, depth):
    """Emit a heading node and its children at the given typst depth."""
    heading = "=" * depth
    m = EX_RE.match(node.title)
    out.append("%s %s" % (heading, inline(node.title)))
    out.append("")
    emit_items([it for it in node.items if not isinstance(it, Node)], out)
    for child in node.items:
        if isinstance(child, Node):
            emit_node(child, out, depth + 1)


def emit_chapter_body(items, out, depth=2):
    for it in items:
        if isinstance(it, Node):
            m = EX_RE.match(it.title)
            if m:
                label = m.group(1)
                project = bool(m.group(2))
                open_exercise(it, out, label, project)
                continue
            out.append("%s %s" % ("=" * depth, inline(it.title)))
            out.append("")
            emit_items([x for x in it.items if not isinstance(x, Node)], out)
            for child in it.items:
                if isinstance(child, Node):
                    emit_chapter_body([child], out, depth + 1)
        else:
            emit_items([it], out)


def open_exercise(node, out, label, project):
    fn = "exercise" if not SOLUTIONS_MODE else "soln"
    if fn == "exercise":
        head = '#exercise("%s"%s)[' % (label, ", project: true" if project else "")
    else:
        head = '#soln("%s")[' % label
    out.append(head)
    inner = []
    emit_items([x for x in node.items if not isinstance(x, Node)], inner)
    for child in node.items:
        if isinstance(child, Node):
            emit_chapter_body([child], inner, 3)
    for line in inner:
        out.append("  " + line if line else "")
    out.append("]")
    out.append("")


SOLUTIONS_MODE = False

MAIN_TEMPLATE = '''#import "lib.typ": *

// ============================================================
//  Thinking in Common Lisp
//  Generated from lisp.org by .edit-work/org2typst.py
// ============================================================

#set document(
  title: "Thinking in Common Lisp",
  author: "Written for Shaul Khayyat",
)

#set page(
  paper: "us-letter",
  margin: (x: 1.15in, y: 1.05in),
  numbering: "1",
  number-align: center,
)

#set text(
  font: ("New Computer Modern", "Libertinus Serif"),
  size: 10.5pt,
  lang: "en",
)

#set par(justify: true, leading: 0.68em, spacing: 1.05em, first-line-indent: 0em)

#set heading(numbering: none)

// Chapters are labelled CHAPTER, the appendices APPENDIX.
#let section-word = state("section-word", "CHAPTER")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  reset-counters
  block(above: 0pt, below: 20pt)[
    #set text(size: 20pt, weight: "bold", fill: accent)
    #if it.numbering != none [
      #context text(size: 13pt, fill: luma(120))[#section-word.get() #counter(heading).display()]
      #linebreak()
    ]
    #it.body
  ]
}

#show heading.where(level: 2): it => block(above: 20pt, below: 9pt)[
  #set text(size: 13.5pt, weight: "bold", fill: accent)
  #it
]

#show heading.where(level: 3): it => block(above: 14pt, below: 7pt)[
  #set text(size: 11.5pt, weight: "bold", style: "italic")
  #it
]

#show heading.where(level: 4): it => block(above: 12pt, below: 6pt)[
  #set text(size: 10.5pt, weight: "bold")
  #it
]

#show link: set text(fill: rgb("#0b4f9c"))

// Code: monospace, a shade smaller, on a tinted panel.
#show raw: set text(font: ("DejaVu Sans Mono", "Libertinus Mono"), size: 8.4pt)
#show raw.where(lang: "lisp-s"): set text(size: 7.2pt)
#show raw.where(lang: "text-s"): set text(size: 7.2pt)
#show raw.where(block: true): it => block(
  width: 100%,
  inset: (x: 9pt, y: 7pt),
  radius: 2pt,
  fill: rgb("#f7f7f8"),
  stroke: 0.4pt + luma(205),
  it,
)

// ---------------- title page ----------------

#page(numbering: none, header: none)[
  #v(1.6in)
  #align(center)[
    #text(size: 15pt, tracking: 2pt, fill: luma(110))[A HAND-HELD GUIDE AND REFERENCE]
    #v(10pt)
    #text(size: 34pt, weight: "bold", fill: accent)[Thinking in Common Lisp]
    #v(20pt)
    #line(length: 45%, stroke: 0.8pt + luma(160))
    #v(20pt)
    #block(width: 74%)[
      #set par(justify: false)
      #set text(size: 11.5pt, fill: luma(60))
      From the REPL to a shipped executable: expressions, lists, functions,
      recursion, macros, conditions, CLOS and packages, then interop,
      generators, testing and a program you build one chapter at a time.
      Every example is code you run as you read it.
    ]
    #v(40pt)
    #text(size: 10.5pt, fill: luma(90))[No forward references. Nothing skipped.]
  ]
  #v(1fr)
  #align(center)[#text(size: 9.5pt, fill: luma(130))[Prepared for Shaul Khayyat #sym.dot.c August 2026]]
]

// ---------------- contents ----------------

#page(numbering: none, header: none)[
  #text(size: 18pt, weight: "bold", fill: accent)[Contents]
  #v(12pt)
  #outline(depth: 1, indent: 1.2em, title: none)
]

#counter(page).update(1)
#set page(header: context {
  let cur = here().page()
  let all = query(heading.where(level: 1))
  let opens-here = all.filter(h => h.location().page() == cur)
  let earlier = all.filter(h => h.location().page() < cur)
  // No running head on a page that opens a chapter, or before the first one.
  if opens-here.len() == 0 and earlier.len() > 0 {
    set text(size: 8.5pt, fill: luma(130))
    grid(
      columns: (1fr, auto),
      align(left)[Thinking in Common Lisp],
      align(right)[#earlier.last().body],
    )
    v(-6pt)
    line(length: 100%, stroke: 0.4pt + luma(200))
  }
})

'''


def write_main(includes):
    front = [i for i in includes if i.startswith("chapters/00-")]
    body = [i for i in includes if i.startswith("parts/") or
            (i.startswith("chapters/") and not i.startswith("chapters/00-") and
             not i.startswith("chapters/Z-"))]
    back = [i for i in includes if i.startswith("chapters/Z-")]
    out = [MAIN_TEMPLATE]
    out.append("#include \"%s\"\n\n" % front[0])
    out.append('#set heading(numbering: "1.")\n#counter(heading).update(0)\n\n')
    appx_seen = False
    for inc in body:
        is_appendix = re.match(r"chapters/[A-I]-", inc) is not None
        if is_appendix and not appx_seen:
            out.append('#set heading(numbering: "A.")\n#counter(heading).update(0)\n#section-word.update("APPENDIX")\n\n')
            appx_seen = True
        out.append("#include \"%s\"\n" % inc)
    if back:
        out.append("\n#set heading(numbering: none)\n")
        for inc in back:
            out.append("#include \"%s\"\n" % inc)
    open(os.path.join(OUT, "main.typ"), "w").write("".join(out))


def slug(title):
    s = title.lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s


def main():
    global SOLUTIONS_MODE
    lines = open(SRC, encoding="utf-8").read().split("\n")
    root = parse(dedent_blocks(lines))

    chapters_dir = os.path.join(OUT, "chapters")
    parts_dir = os.path.join(OUT, "parts")
    os.makedirs(chapters_dir, exist_ok=True)
    os.makedirs(parts_dir, exist_ok=True)
    for d in (chapters_dir, parts_dir):
        for f in os.listdir(d):
            if f.endswith(".typ"):
                os.remove(os.path.join(d, f))

    includes = []
    partno = 0
    chapno = 0
    appno = 0

    def emit_part_children(part_node, part_file_out):
        nonlocal chapno
        for ch in part_node.items:
            if not isinstance(ch, Node):
                continue
            t = ch.title
            if re.fullmatch(r"Part [IVX]+ review", t):
                out = ['#import "../lib.typ": *', ""]
                out.append('#heading(level: 1, numbering: none)[%s]' % inline(t))
                out.append("")
                emit_chapter_body(ch.items, out, 2)
                name = "parts/part-%d-review.typ" % partno
                open(os.path.join(OUT, name), "w").write("\n".join(out) + "\n")
                includes.append(name)
                continue
            if not t.startswith("Chapter "):
                # A section that belongs to the part itself, before its first
                # chapter. It is not a chapter, so it carries no chapter
                # number: numbered, it would read "0.1".
                part_file_out.append(
                    '#heading(level: 2, numbering: none)[%s]' % inline(t))
                part_file_out.append("")
                emit_chapter_body(ch.items, part_file_out, 3)
                continue
            chapno += 1
            m = re.match(r"^Chapter (\d+):\s*(.*)$", t)
            num, title = (m.group(1), m.group(2)) if m else (str(chapno), t)
            out = ['#import "../lib.typ": *', ""]
            out.append("= %s" % inline(title))
            out.append("")
            emit_chapter_body(ch.items, out, 2)
            name = "chapters/%02d-%s.typ" % (int(num), slug(title))
            open(os.path.join(OUT, name), "w").write("\n".join(out) + "\n")
            includes.append(name)

    for node in root.items:
        if not isinstance(node, Node):
            continue
        t = node.title
        if t.startswith("Part "):
            partno += 1
            m = re.match(r"^Part ([IVX]+):\s*(.*)$", t)
            num, title = (m.group(1), m.group(2)) if m else (str(partno), t)
            out = ['#import "../lib.typ": *', ""]
            out.append('#part("%s", "%s")' % (num, title))
            out.append("")
            out.append("#part-intro[")
            inner = []
            emit_items([x for x in node.items if not isinstance(x, Node)], inner)
            out.extend("  " + l for l in inner)
            out.append("]")
            out.append("")
            name = "parts/part-%d.typ" % partno
            includes.append(name)
            emit_part_children(node, out)
            open(os.path.join(OUT, name), "w").write("\n".join(out))
            continue
        if t.startswith("Appendix "):
            appno += 1
            m = re.match(r"^Appendix ([A-Z]):\s*(.*)$", t)
            num, title = (m.group(1), m.group(2)) if m else ("A", t)
            SOLUTIONS_MODE = title.lower().startswith("answers")
            out = ['#import "../lib.typ": *', ""]
            out.append("= %s" % inline(title))
            out.append("")
            emit_chapter_body(node.items, out, 2)
            SOLUTIONS_MODE = False
            name = "chapters/%s-%s.typ" % (num, slug(title))
            open(os.path.join(OUT, name), "w").write("\n".join(out) + "\n")
            includes.append(name)
            continue
        if t == H1_FRONT:
            out = ['#import "../lib.typ": *', ""]
            out.append("= %s" % inline(t))
            out.append("")
            emit_chapter_body(node.items, out, 2)
            name = "chapters/00-front.typ"
            open(os.path.join(OUT, name), "w").write("\n".join(out) + "\n")
            includes.append(name)
            continue
        if t.startswith("Colophon"):
            out = ['#import "../lib.typ": *', ""]
            out.append("= %s" % inline(t))
            out.append("")
            emit_chapter_body(node.items, out, 2)
            name = "chapters/Z-colophon.typ"
            open(os.path.join(OUT, name), "w").write("\n".join(out) + "\n")
            includes.append(name)
            continue
        print("UNHANDLED h1:", t, file=sys.stderr)

    open(os.path.join(OUT, "includes.txt"), "w").write("\n".join(includes) + "\n")
    write_main(includes)
    print("chapters %d, parts %d, appendices %d, files %d" % (chapno, partno, appno, len(includes)))
    if SUSPECT:
        print("suspicious code spans: %d" % len(SUSPECT))
        seen = set()
        for lineno, code in SUSPECT:
            if lineno in seen:
                continue
            seen.add(lineno)
            print("  %d: %r" % (lineno, code[:90]))


if __name__ == "__main__":
    main()
