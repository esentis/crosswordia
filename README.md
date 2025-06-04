# CrossWordia

#### A mobile game similar to Words of Wonders made with Flutter.

This is an **_unfinished_** thesis project.

<image src="crosswordia.gif" height="500"> </image>

# Algorithms

# Word Scoring Algorithm Analysis

## Algorithm Overview

The `calculateWordScore` algorithm computes a numerical score for words in a crossword puzzle based on **letter rarity** and **word length**. It implements a frequency-based scoring system where rare letters contribute more points.

## Mathematical Representation

### Problem Definition

Let:

- **$W$** = input word, $W = w₁w₂...wₙ$ where $n = |W|$
- **$freq(w)$** = frequency of letter $w$ in the language (from lookup table)
- **$valid(w)$** = predicate indicating if $w$ is a valid single letter
- **$Score(W)$** = calculated score for word $W$

### Mathematical Formulation

$$\text{Score}(W) = \sum_{i=1}^{n} \text{LetterScore}(w_i) + \text{LengthBonus}(W)$$

Where:

**Letter Score Function:**

$$
\text{LetterScore}(w_i) = \begin{cases}
\left\lfloor \frac{1}{\text{freq}(w_i)} + 0.5 \right\rfloor & \text{if } \text{valid}(w_i) \wedge \text{freq}(w_i) > 0 \\
0 & \text{otherwise}
\end{cases}
$$

**Length Bonus Function:**
$$\text{LengthBonus}(W) = 10 \times |W|$$

**Complete Score Formula:**

$$
\text{Score}(W) = \sum_{i=1}^{n} \begin{cases}
\left\lfloor \frac{1}{\text{freq}(w_i)} + 0.5 \right\rfloor & \text{if } \text{valid}(w_i) \wedge \text{freq}(w_i) > 0 \\
0 & \text{otherwise}
\end{cases} + 10n
$$

### Algorithm Steps

1. **Initialization:** $\text{score} \leftarrow 0$

2. **Letter Processing:**
   $$\forall w_i \in W: \text{score} \leftarrow \text{score} + \text{LetterScore}(w_i)$$

3. **Length Bonus Addition:**
   $$\text{score} \leftarrow \text{score} + 10 \times |W|$$

4. **Return:** $\text{score}$

### Scoring Properties

**Inverse Frequency Principle:**

- High-frequency letters → Low scores
- Low-frequency letters → High scores
- Invalid/unknown letters → Zero contribution

**Length Incentive:**

- Longer words receive significant bonus (10 points per letter)
- Encourages placement of longer words in crossword

## Complexity Analysis

### Time Complexity

**$O(n)$** where $n = |W|$ (word length)

**Detailed Breakdown:**

- **Main loop:** $O(n)$ iterations
- **Per iteration operations:**
  - `onlyLetters.length`: $O(k)$ where $k = \text{letter length} \approx O(1)$
  - `toGreekUpperCase()`: $O(1)$ for single character
  - Map lookup `letterFrequencies[...]`: $O(1)$ average case
  - Arithmetic operations: $O(1)$
- **Length bonus calculation:** $O(1)$

**Overall:** $O(n \times 1) = O(n)$

### Space Complexity

**$O(1)$** - excluding input storage

- Constant additional variables (`score`, `letterFreq`)
- No dynamic data structures created
- Input string dominates space usage

### Practical Complexity Bounds

For typical crossword words:

- $n ≤ 15$ (most words under 15 letters)
- **Practical Time:** $O(15) = O(1)$ for bounded word lengths

## Algorithm Characteristics

### Best Case

- **$O(n)$**: Must process every letter regardless
- No early termination possible

### Worst Case

- **$O(n)$**: Same as best case
- Linear scan is unavoidable

### Average Case

- **$O(n)$**: Consistent linear performance

## Scoring Examples with Actual Greek Frequencies

### Example 1: "ΚΑΛΟΣ" (GOOD)

Using actual Greek letter frequencies:

- Κ: freq = 0.03974 → score = round(1/0.03974) = **25 points**
- Α: freq = 0.11411 → score = round(1/0.11411) = **9 points**
- Λ: freq = 0.02732 → score = round(1/0.02732) = **37 points**
- Ο: freq = 0.10331 → score = round(1/0.10331) = **10 points**
- Σ: freq = 0.07830 → score = round(1/0.07830) = **13 points**

**Letter Score:** 25 + 9 + 37 + 10 + 13 = 94
**Length Bonus:** 5 × 10 = 50
**Total Score:** **144 points**

### Example 2: "ΨΩΖ" (rare letters)

- Ψ: freq = 0.00133 → score = round(1/0.00133) = **752 points**
- Ω: freq = 0.02147 → score = round(1/0.02147) = **47 points**
- Ζ: freq = 0.00345 → score = round(1/0.00345) = **290 points**

**Letter Score:** 752 + 47 + 290 = 1089
**Length Bonus:** 3 × 10 = 30
**Total Score:** **1119 points**

### Letter Value Rankings (Points per Letter)

**Highest Value (Rare Letters):**

- Ψ: 752 points (0.133% frequency)
- Ζ: 290 points (0.345% frequency)
- Ξ: 249 points (0.402% frequency)
- Β: 147 points (0.682% frequency)

### Letter Value Rankings (Points per Letter)

**Highest Value (Rare Letters):**

- Ψ: 752 points (0.133% frequency)
- Ζ: 290 points (0.345% frequency)
- Ξ: 249 points (0.402% frequency)
- Β: 147 points (0.682% frequency)

**Lowest Value (Common Letters):**

- Α: 9 points (11.411% frequency)
- Ο: 10 points (10.331% frequency)
- Ι: 11 points (9.252% frequency)
- Ε: 12 points (8.586% frequency)

### Frequency Distribution Analysis

**Greek Letter Frequency Tiers:**

**Tier 1 - Very Common (>7%):** Α, Ο, Ι, Ε, Τ, Σ (6 letters)

- Contribute 9-13 points each
- Form the backbone of most words

**Tier 2 - Common (3-7%):** Ν, Η, Υ, Ρ, Π, Κ, Μ (7 letters)

- Contribute 15-30 points each
- Good balance of usage and value

**Tier 3 - Uncommon (1-3%):** Λ, Ω, Δ, Γ (4 letters)

- Contribute 37-58 points each
- Valuable tactical letters

**Tier 4 - Rare (<1%):** Χ, Θ, Φ, Β, Ξ, Ζ, Ψ (7 letters)

- Contribute 85-752 points each
- High-value target letters

### Strategic Implications

**High-Scoring Strategy:**

1. **Target rare letters:** Words with Ψ, Ζ, Ξ provide massive point bonuses
2. **Length optimization:** 10 points per letter makes longer words valuable
3. **Balance approach:** Mix of rare letters + length maximizes scores

### Strategic Implications

**High-Scoring Strategy:**

1. **Target rare letters:** Words with Ψ, Ζ, Ξ provide massive point bonuses
2. **Length optimization:** 10 points per letter makes longer words valuable
3. **Balance approach:** Mix of rare letters + length maximizes scores

**Score Distribution Pattern:**

- **Short rare words:** Can score 500-1000+ points
- **Long common words:** Score 150-300 points consistently
- **Optimal sweet spot:** Medium words (5-8 letters) with 1-2 rare letters

### Mathematical Properties of Greek Frequency Distribution

**Frequency Statistics:**

- **Mean frequency:** μ = 0.04167 (1/24 letters)
- **Median frequency:** ~0.03666 (between Κ and Μ)
- **Standard deviation:** σ ≈ 0.0345
- **Distribution:** Highly skewed toward common letters

**Scoring Implications:**

- **Point range:** 9 to 752 points per letter
- **Most letters (75%)** score between 9-50 points
- **Rare letters (25%)** score 58-752 points
- **Exponential scoring curve:** Small frequency changes = large point differences

**Zipf-like Distribution:**
The Greek letter frequencies follow approximately:
$f_{\text{rank}} \propto \frac{1}{\text{rank}^{0.7}}$

This creates the inverse scoring pattern where:
$\text{points}_{\text{rank}} \propto \text{rank}^{0.7}$

## Design Analysis

### Strengths

1. **Simple and Efficient:** Linear time complexity
2. **Frequency-Based:** Rewards rare letter usage
3. **Length Incentive:** Encourages longer words
4. **Robust:** Handles invalid letters gracefully

### Potential Optimizations

1. **Frequency Caching:** Pre-compute inverse frequencies
2. **Batch Processing:** Score multiple words simultaneously
3. **Early Validation:** Check letter validity before frequency lookup

## Crossword Placement Algorithm Analysis

### Algorithm Overview

Both algorithms solve the word placement feasibility problem in crossword puzzles, determining whether a word can be placed horizontally or vertically on a grid without conflicts.

### Mathematical Representation

#### Problem Definition

Let:

$G$ = crossword grid of size $R × C$ (R rows, C columns)
$W$ = word to place, $W = w₁w₂...wₙ$ where $n = |W|$
$L$ = set of already placed letters with positions
$P(r,c)$ = position at row $r$, column $c$
$Occupied(r,c)$ = letter at position $(r,c)$ if occupied, ∅ otherwise

### Horizontal Placement Algorithm

Input: Word $W$, intersection point $P(r₀,c₀)$, letter index $i$
Objective: Determine if $W$ can be placed horizontally starting at position $P(r₀, c₀-i)$
Mathematical Formulation:
$$\text{canStartHorizontally}(W, r_0, c_0, i) = \bigwedge_{k=0}^{n-1} \Phi_h(k)$$
Where $\Phi_h(k)$ represents the conflict-free condition for position $k$:
$$\Phi_h(k) = \neg\text{Conflict}_h(r_0, c_0-i+k, w_{k+1})$$
Where $\Phi_h(k)$ represents the conflict-free condition for position k:
$$\Phi_h(k) = \neg\text{Conflict}_h(r_0, c_0-i+k, w_{k+1})$$

#### Conflict Detection Function:

$\text{BoundaryViolation}(r, c) $
$\text{LetterMismatch}(r, c, w) $
$\text{AdjacentConflict}(r, c) $
$\text{EndpointConflict}(r, c) $

**Component Functions:**

1. **Boundary Violation:**
   $\text{BoundaryViolation}(r, c) = (c < 1) \vee (c > C)$

2. **Letter Mismatch:**
   $\text{LetterMismatch}(r, c, w) = \text{Occupied}(r, c) \neq \emptyset \wedge \text{Occupied}(r, c) \neq w \wedge P(r, c) \neq P(r_0, c_0)$

3. **Adjacent Conflict:**
   $\text{AdjacentConflict}(r, c) = \text{Occupied}(r, c) = \emptyset \wedge \left(\text{Occupied}(r-1, c) \neq \emptyset \vee \text{Occupied}(r+1, c) \neq \emptyset\right)$

4. **Endpoint Conflict:**
   $\text{EndpointConflict}(r, c) = \text{Occupied}(r, c_{start}-1) \neq \emptyset \vee \text{Occupied}(r, c_{end}+1) \neq \emptyset$

### Vertical Placement Algorithm

**Mathematical Formulation:**

$$\text{canStartVertically}(W, r_0, c_0, i) = \bigwedge_{k=0}^{n-1} \Phi_v(k)$$

Where $\Phi_v(k)$ is similar to $\Phi_h(k)$ but with row and column coordinates swapped:

$$\Phi_v(k) = \neg\text{Conflict}_v(r_0-i+k, c_0, w_{k+1})$$

The conflict detection is analogous but checks left/right adjacency instead of top/bottom.

## Complexity Analysis

### Time Complexity

**Primary Loop:** O(n) where n = |W| (word length)

**Per Iteration Operations:**

- `whereValue()` operation: $O(L)$ where $L = |letterPositions|$
- `anyValue()` operations (5 calls): $O(5L) = O(L)$
- String operations: $O(1)$

**Overall Time Complexity:** **$O(n × L)$**

Where:

- $n$ = length of word being placed
- $L$ = number of letters already placed on the board

### Space Complexity

**$O(1)$** - excluding input storage

- Constant additional variables
- No recursive calls or dynamic data structures
- Input parameters dominate space usage

### Practical Complexity Bounds

In a typical crossword scenario:

- $n ≤ 15$ (most words are under 15 letters)
- $L ≤ R × C$ (at most every cell is filled)
- For a $15×15$ grid: $L ≤ 225$

**Practical Time Complexity:** $O(15 × 225) = O(3,375) = O(1)$ for fixed-size grids

## Algorithm Efficiency Characteristics

### Best Case

- **$O(1)$**: Immediate boundary violation or space insufficiency
- Early termination on first conflict

### Worst Case

- **$O(n × L)$**: Full word iteration with complete letterPositions traversal
- No conflicts found, full validation required

### Average Case

- **$O(n × L/2)$**: Conflicts typically found mid-way through validation
- Practical performance much better than worst case

## Optimization Opportunities

1. **Spatial Indexing:** Use 2D array instead of hash map for $O(1)$ position lookups
2. **Early Termination:** More aggressive boundary checking
3. **Caching:** Store conflict results for repeated placements
4. **Incremental Updates:** Update only affected regions when adding letters

The algorithms are well-designed for their purpose, with reasonable complexity for crossword puzzle constraints.
