# Hamming(12,8) — Theory & Worked Example

## What is a Hamming Code?

A Hamming code is a linear error-correcting code that inserts redundant **parity bits** at power-of-2 positions in a codeword. Each parity bit is responsible for checking a specific subset of bit positions. When a bit is flipped during transmission, the set of failing parity checks uniquely identifies the erroneous position.

---

## Why Hamming(12,8)?

| Parameter        | Value |
|------------------|-------|
| Data bits (k)    | 8     |
| Parity bits (r)  | 4     |
| Total bits (n)   | 12    |
| Error capability | Correct 1 bit, Detect 2 bits |
| Code rate        | 8/12 = 66.7% |

The minimum number of parity bits `r` needed for `k` data bits satisfies:
```
2^r ≥ k + r + 1
2^4 = 16 ≥ 8 + 4 + 1 = 13  ✓
```

---

## Codeword Construction (Encoding)

Given 8-bit data `D = d7 d6 d5 d4 d3 d2 d1 d0`, the 12-bit codeword is:

```
Position (1-indexed): 12  11  10   9   8   7   6   5   4   3   2   1
Bit assignment:        d7  d6  d5  d4  P8  d3  d2  d1  P4  d0  P2  P1
Codeword index (0-idx):11  10   9   8   7   6   5   4   3   2   1   0
```

### Parity equations (even parity)

```
P1 = d0 ⊕ d1 ⊕ d3 ⊕ d4 ⊕ d6
P2 = d0 ⊕ d2 ⊕ d3 ⊕ d5 ⊕ d6
P4 = d1 ⊕ d2 ⊕ d3 ⊕ d7
P8 = d4 ⊕ d5 ⊕ d6 ⊕ d7
```

---

## Worked Example

### Encode `0xAA = 10101010`

Data bits: `d7=1, d6=0, d5=1, d4=0, d3=1, d2=0, d1=1, d0=0`

```
P1 = d0⊕d1⊕d3⊕d4⊕d6 = 0⊕1⊕1⊕0⊕0 = 0
P2 = d0⊕d2⊕d3⊕d5⊕d6 = 0⊕0⊕1⊕1⊕0 = 0
P4 = d1⊕d2⊕d3⊕d7    = 1⊕0⊕1⊕1   = 1
P8 = d4⊕d5⊕d6⊕d7    = 0⊕1⊕0⊕1   = 0
```

Codeword: `d7 d6 d5 d4 P8 d3 d2 d1 P4 d0 P2 P1`
        = `1  0  1  0  0  1  0  1  1  0  0  0`
        = `101010110100` (MSB first, index 11 down to 0)

---

### Inject error at codeword index 5 (1-indexed position 6)

Flip bit 5: `101010110100` → `101010010100`

### Decode: Recompute parity from received codeword

```
Received: pos12 pos11 pos10 pos9 pos8 pos7 pos6 pos5 pos4 pos3 pos2 pos1
               1     0     1    0    0    1    0    1    1    0    0    0
```

But after flipping index 5 (position 6):
```
pos6 was 0, now 1 → received = ...1...
```

Recompute:
```
p1_calc = pos3 ⊕ pos5 ⊕ pos7 ⊕ pos9 ⊕ pos11 = 0⊕1⊕1⊕0⊕0 = 0 → matches stored P1=0 → syndrome[0]=0
p2_calc = pos3 ⊕ pos6 ⊕ pos7 ⊕ pos10 ⊕ pos11 = 0⊕1⊕1⊕1⊕0 = 1 → stored P2=0 → syndrome[1]=1
p4_calc = pos5 ⊕ pos6 ⊕ pos7 ⊕ pos12 = 1⊕1⊕1⊕1 = 0 → stored P4=1 → syndrome[2]=1
p8_calc = pos9 ⊕ pos10 ⊕ pos11 ⊕ pos12 = 0⊕1⊕0⊕1 = 0 → matches P8=0 → syndrome[3]=0
```

Syndrome = `0110` (binary) = **6** (decimal)

Error is at position 6 → flip codeword[5] → codeword restored → data = `0xAA` ✓

---

## Why the syndrome equals the error position

Each parity bit Pi covers all positions whose binary representation has bit `i` set:
- P1 covers positions where bit 0 = 1: 1, 3, 5, 7, 9, 11
- P2 covers positions where bit 1 = 1: 2, 3, 6, 7, 10, 11
- P4 covers positions where bit 2 = 1: 4, 5, 6, 7, 12
- P8 covers positions where bit 3 = 1: 8, 9, 10, 11, 12

If position 6 is flipped:
- Binary of 6 = `0110`
- P1 check passes (bit 0 of 6 = 0)
- P2 check fails  (bit 1 of 6 = 1) → syndrome[1] = 1
- P4 check fails  (bit 2 of 6 = 1) → syndrome[2] = 1
- P8 check passes (bit 3 of 6 = 0)

Syndrome = `0110` = 6. The binary representation of the erroneous position IS the syndrome. This is the elegance of Hamming codes.
