#import "../lib.typ": *

= Graphs

== The most reusable abstraction in computing

A graph is a set of things and a set of connections between them. That is
almost content-free as a definition, and that is exactly why it is useful: an
enormous range of problems turn out to be graph problems once you name the
right things and the right connections.

This chapter is the mathematics. The algorithms you probably already know; the
point here is the theory that tells you when they work and why.

#definition(title: "graph")[
  A *graph* is a pair $G = (V, E)$ where $V$ is a finite set of *vertices* and
  $E$ is a set of *edges*.

  In an *undirected* graph an edge is an unordered pair ${u,v\}$; in a
  *directed* graph (a *digraph*) it is an ordered pair $(u,v)$.

  Unless stated otherwise we assume *simple* graphs: no self-loops
  ${v,v\}$ and no repeated edges. A graph allowing repeats is a *multigraph*.
]

Note that a directed graph is exactly a *relation* on $V$ (Chapter 8), and an
undirected graph is exactly a *symmetric* relation. Everything you learned
about relations applies: reflexive means every vertex has a self-loop,
transitive means every path of length two is shortcut by an edge.

#definition(title: "degree")[
  In an undirected graph, $deg(v)$ is the number of edges incident to $v$. In
  a digraph we distinguish $deg^-(v)$ (in-degree) and $deg^+(v)$ (out-degree).
]

#theorem(title: "handshake lemma")[
  For any undirected graph, $ sum_(v in V) deg(v) = 2 abs(E). $
]

#proof[
  Count the pairs $(v, e)$ where $v$ is an endpoint of $e$, in two ways.
  Grouping by vertex gives $sum_v deg(v)$. Grouping by edge gives $2 abs(E)$,
  since each edge has exactly two endpoints.
]

#corollary[
  In any graph, the number of vertices of odd degree is even.
]

#proof[
  The total degree is even by the lemma. The even-degree vertices contribute
  an even amount, so the odd-degree vertices must contribute an even amount
  too --- and a sum of odd numbers is even only if there is an even number of
  them.
]

That is a double-counting proof, exactly the technique of Chapter 9, and it is
the prototype for graph theory generally: *count something two ways*.

== Paths, cycles, connectivity

#definition(title: "walk, path, cycle")[
  A *walk* is a sequence of vertices with consecutive ones adjacent. A *path*
  is a walk with no repeated vertex. A *cycle* is a walk of length at least 3
  that starts and ends at the same vertex, with no other repeats.

  $G$ is *connected* if there is a path between every pair of vertices. A
  *connected component* is a maximal connected subgraph.
]

#proposition[
  "There is a path from $u$ to $v$" is an equivalence relation on the vertices
  of an undirected graph, and its equivalence classes are the connected
  components.
]

#proof[
  Reflexive: the length-zero path from $u$ to itself. Symmetric: reverse the
  path. Transitive: concatenate the two walks, and any walk from $u$ to $w$
  contains a path from $u$ to $w$ (delete the segment between any two
  occurrences of a repeated vertex, repeatedly; this strictly shortens the
  walk each time so it terminates, by well-ordering, Chapter 7).

  By the partition theorem of Chapter 8, the classes partition $V$, and by
  construction each class is a maximal connected set.
]

That proposition is why `find_components` via BFS or union-find is correct:
the components are genuinely a partition, so every vertex belongs to exactly
one, and you can label them independently.

== Trees

#definition(title: "tree")[
  A *tree* is a connected acyclic undirected graph. A *forest* is an acyclic
  graph (each component a tree).
]

#theorem(title: "characterisations of a tree")[
  For a graph $G$ with $n$ vertices, the following are equivalent:

  #set enum(numbering: "(i)")
  + $G$ is a tree.
  + $G$ is connected and has exactly $n - 1$ edges.
  + $G$ is acyclic and has exactly $n - 1$ edges.
  + There is exactly one path between every pair of vertices.
  + $G$ is connected, and removing any edge disconnects it.
  + $G$ is acyclic, and adding any edge creates a cycle.
]

#proof[
  We prove (i) $arrow.r.double$ (iv) $arrow.r.double$ (v), and
  (i) $arrow.r.double$ (ii), which is the substance; the rest follow by
  similar arguments.

  *(i) $arrow.r.double$ (iv).* Connectedness gives at least one path. If there
  were two distinct paths from $u$ to $v$, walk along the first until it first
  diverges from the second, then follow it to the first vertex where the two
  meet again (they must, since both end at $v$). The two segments between
  those points form a cycle --- contradiction.

  *(iv) $arrow.r.double$ (v).* Connectedness is immediate. Remove edge
  ${u,v\}$. If $u$ and $v$ were still connected there would be a path from $u$
  to $v$ avoiding the edge, which together with the edge gives two distinct
  paths, contradicting uniqueness.

  *(i) $arrow.r.double$ (ii).* Induction on $n$. For $n = 1$ a tree has $0$
  edges. Suppose the claim for all trees with fewer than $n$ vertices, and let
  $T$ have $n >= 2$ vertices. $T$ has a *leaf* (a vertex of degree 1): follow
  a longest path in $T$; its endpoint cannot have another neighbour, since
  that neighbour is either on the path (creating a cycle) or off it (making
  the path longer). Delete that leaf and its edge. The result is still
  connected and acyclic --- a tree on $n-1$ vertices --- so by hypothesis it
  has $n - 2$ edges. Adding the leaf back gives $n-1$.
]

#intuition(title: "a tree is the minimum connectivity")[
  $n-1$ edges is exactly the amount of connection needed and no more. Below
  it you are disconnected; above it you have a cycle, meaning redundancy.

  This is why: a spanning tree is the cheapest way to connect a network; why a
  minimum spanning tree has $n-1$ edges; why an $n$-node distributed system
  needs $n-1$ links to be connected and any extra link creates an alternate
  route; and why a rooted tree with $n$ nodes has $n-1$ parent pointers, one
  per non-root node.
]

== Bipartite graphs

#definition(title: "bipartite")[
  $G$ is *bipartite* if $V$ splits into two disjoint sets $V_1, V_2$ such that
  every edge joins a vertex of $V_1$ to one of $V_2$. Equivalently, $G$ is
  2-colourable.
]

#theorem(title: "König's characterisation")[
  $G$ is bipartite if and only if it contains no cycle of odd length.
]

#proof[
  ($arrow.r.double$) Walking along a cycle alternates sides at every step, so
  returning to the start requires an even number of steps.

  ($arrow.l.double$) Assume $G$ is connected (otherwise argue per component).
  Pick any vertex $r$ and define
  $ V_1 = {v : d(r,v) "even"}, quad V_2 = {v : d(r,v) "odd"}, $
  where $d$ is the shortest-path distance. Suppose some edge ${u,v\}$ had both
  endpoints in the same part, so $d(r,u)$ and $d(r,v)$ have the same parity.
  Then the shortest path $r arrow.squiggly u$, the edge $u v$, and the reverse
  of the shortest path $v arrow.squiggly r$ form a closed walk of odd length,
  which must contain an odd cycle. Contradiction.
]

That proof is literally the algorithm: run BFS, colour by the parity of the
level, and check every edge. If you find an edge inside a level, you have
found an odd cycle. Bipartiteness testing is a BFS with one extra check, and
the theorem is why.

== Eulerian and Hamiltonian

Two questions that look similar and are wildly different in difficulty --- a
distinction worth internalising, because it recurs everywhere in complexity.

#definition[
  An *Eulerian circuit* uses every *edge* exactly once and returns to the
  start. A *Hamiltonian cycle* visits every *vertex* exactly once and returns
  to the start.
]

#theorem(title: "Euler, 1736")[
  A connected graph has an Eulerian circuit if and only if every vertex has
  even degree.
]

#proof[
  ($arrow.r.double$) Each time the circuit visits a vertex it enters by one
  edge and leaves by another, pairing up the edges at that vertex. So every
  degree is even.

  ($arrow.l.double$) Suppose all degrees are even. Start anywhere and walk,
  never reusing an edge. You can never get stuck at a vertex other than the
  start: arriving at $v != "start"$ uses up one edge, leaving an odd number of
  unused edges at $v$, so at least one remains to leave by. So the walk
  terminates only by returning to the start, giving a closed circuit $C$.

  If $C$ uses every edge, done. Otherwise, since the graph is connected, some
  vertex $w$ on $C$ has unused edges. The unused edges also form a graph with
  all degrees even (we removed a circuit, which removes an even number at each
  vertex), so by the same argument there is a circuit $C'$ through $w$ in the
  leftovers. Splice $C'$ into $C$ at $w$. Repeat; the number of unused edges
  strictly decreases, so this terminates.
]

That proof is Hierholzer's algorithm, and it runs in linear time.

Hamiltonicity, meanwhile, has *no* such characterisation. Deciding whether a
Hamiltonian cycle exists is NP-complete. Nobody knows a condition that is both
necessary and sufficient and checkable quickly.

#intuition(title: "why edges are easy and vertices are hard")[
  The Euler proof works because the constraint is *local*: each vertex only
  cares about its own degree, and local constraints can be verified and
  repaired independently. The splicing step is possible precisely because
  fixing one place does not break another.

  Hamiltonicity is a *global* constraint --- whether you can visit everything
  once depends on the whole structure at once, and a local fix anywhere can
  destroy the solution elsewhere. That gap between local and global
  verifiability is, informally, the gap between P and NP.
]

== Planarity and colouring

#definition(title: "planar")[
  A graph is *planar* if it can be drawn in the plane with no edges crossing.
]

#theorem(title: "Euler's formula")[
  For a connected planar graph drawn in the plane with $V$ vertices, $E$
  edges, and $F$ faces (including the unbounded outer face),
  $ V - E + F = 2. $
]

#proof[
  Induction on $E$. If the graph is a tree, then $E = V - 1$ and $F = 1$
  (no cycles, so no bounded faces), giving $V - (V-1) + 1 = 2$.

  Otherwise the graph has a cycle; delete one edge of it. This keeps the graph
  connected (the cycle provided an alternate route) and merges the two faces
  adjacent to that edge into one. So $E$ and $F$ each drop by 1 and the
  alternating sum is unchanged. Repeat until a tree remains.
]

#corollary[
  A simple planar graph with $V >= 3$ has $E <= 3V - 6$.
]

#proof[
  Each face is bounded by at least 3 edges, and each edge borders at most 2
  faces, so $3F <= 2E$, giving $F <= 2E slash 3$. Substituting into Euler's
  formula: $2 = V - E + F <= V - E + 2E slash 3 = V - E slash 3$, hence
  $E <= 3V - 6$.
]

So $K_5$ (five vertices, all $10$ edges) is not planar: $10 > 3 dot 5 - 6 = 9$.
This linear bound is why planar graphs are sparse, and it is why algorithms on
planar graphs (road networks, circuit layouts, meshes) can afford to be
$O(V)$ rather than $O(V^2)$.

The famous *four colour theorem* --- every planar graph is 4-colourable ---
is true, was proved in 1976 with substantial computer assistance, and has
never been given a proof a human can check unaided. The weaker *six colour*
version is a two-line consequence of the corollary above (Exercise).

== Directed graphs and DAGs

#definition(title: "DAG")[
  A *directed acyclic graph* is a digraph with no directed cycles.
]

#theorem(title: "topological ordering")[
  A finite digraph has a topological ordering --- a linear order of the
  vertices in which every edge points forwards --- if and only if it is a DAG.
]

#proof[
  ($arrow.r.double$) If there were a directed cycle, every vertex on it would
  have to precede the next, and the last would have to precede the first ---
  impossible in a linear order.

  ($arrow.l.double$) Suppose $G$ is a DAG. It has a vertex of in-degree $0$:
  otherwise every vertex has a predecessor, so following predecessors backwards
  forever from any starting vertex must revisit a vertex (there are finitely
  many), producing a cycle. Output that vertex, delete it, and repeat on the
  rest, which is still a DAG.
]

Again the proof is the algorithm (Kahn's algorithm), and the failure mode is
informative: if at some point no vertex has in-degree $0$ and vertices remain,
there is a cycle. That is precisely how a build tool reports circular
dependencies.

#definition(title: "strongly connected")[
  A digraph is *strongly connected* if there is a directed path from every
  vertex to every other. The *strongly connected components* are the
  equivalence classes of the relation "$u$ reaches $v$ and $v$ reaches $u$".
]

Contracting each strongly connected component to a single node always yields a
DAG --- the *condensation*. This is the standard structural decomposition of a
digraph: cycles live inside components, and the components themselves have a
clean layered order.

== Graphs as matrices

The bridge to Part IV, and worth planting now.

#definition(title: "adjacency matrix")[
  For a graph on vertices $1, dots, n$, the adjacency matrix $A$ is the
  $n times n$ matrix with $A_(i j) = 1$ if there is an edge from $i$ to $j$,
  and $0$ otherwise.
]

#theorem(title: "powers of the adjacency matrix count walks")[
  $(A^k)_(i j)$ is the number of walks of length exactly $k$ from $i$ to $j$.
]

#proof[
  Induction on $k$. For $k = 1$ this is the definition. Suppose it holds for
  $k$. A walk of length $k+1$ from $i$ to $j$ consists of a walk of length $k$
  from $i$ to some vertex $m$, followed by an edge $m -> j$. Summing over the
  intermediate vertex,
  $ "(number of such walks)" = sum_m (A^k)_(i m) A_(m j) = (A^(k+1))_(i j), $
  which is exactly the definition of matrix multiplication.
]

#intuition(title: "matrix multiplication is path composition")[
  That theorem explains what matrix multiplication *is*. The formula
  $sum_m A_(i m) B_(m j)$ looks arbitrary until you read it as: to get from
  $i$ to $j$ in two stages, sum over all possible middle points. Composition
  of relations, and of functions, and of transformations, all have that shape.

  Replace $(+, times)$ with $(min, +)$ and the same product computes shortest
  paths --- that is the Floyd--Warshall algorithm, which is matrix
  multiplication over a different semiring. Replace them with
  $("or", "and")$ and it computes reachability, which is Warshall's transitive
  closure.

  One algorithm; three semirings.
]

The *Laplacian* $L = D - A$ (where $D$ is the diagonal matrix of degrees) is
where graph theory and linear algebra fuse. Its eigenvalues (Chapter 23)
encode connectivity: the number of zero eigenvalues equals the number of
connected components, and the second-smallest eigenvalue --- the *algebraic
connectivity* --- measures how hard the graph is to cut in two. Spectral
clustering, graph partitioning, and a good deal of modern network analysis are
applications of that one fact.

== Exercises

#exercise[
  A graph has $7$ vertices with degrees $3, 3, 3, 3, 3, 3, 3$. Show no such
  graph exists.
]

#exercise[
  Prove that every tree with at least two vertices has at least two leaves.
]

#exercise[
  Prove that a graph in which every vertex has degree at least 2 contains a
  cycle. (Consider a longest path.)
]

#exercise[
  Determine whether the following graph is bipartite, and if so give the two
  parts: vertices ${1,dots,6\}$, edges $12, 23, 34, 45, 56, 61$. What if you
  add the edge $14$?
]

#exercise[
  The classic Königsberg bridge problem: four landmasses joined by seven
  bridges, with degrees $3, 3, 3, 5$. Explain in one sentence, using Euler's
  theorem, why no walk crosses every bridge exactly once and returns to the
  start. Then state the condition under which such a walk exists if you are
  *not* required to return to the start.
]

#exercise[
  Use $E <= 3V - 6$ to prove that every simple planar graph has a vertex of
  degree at most $5$. Then use that, with induction, to prove every planar
  graph is 6-colourable.
]

#exercise[
  Let $A$ be the adjacency matrix of an undirected graph. What does
  $(A^2)_(i i)$ count? What does $(A^3)_(i i)$ count, and what does
  $tr(A^3) slash 6$ therefore compute?
]

#exercise[
  Prove that in any DAG, the relation "$u$ can reach $v$" is a partial order.
  Which property of partial orders would fail if the graph had a cycle?
]
