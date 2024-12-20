```@meta
CurrentModule = AJD
```

# Getting Started Guide
This guide provides information on implemented algorithms and 
## Background
This module aims to implement the Approximate Joint Diagonalization (AJD) proposed in the paper: 

[1] *Jacobi Angles for Simultaneous Diagonalization* by Jean-François Cardoso and Antoine Souloumiac: SIAM journal on matrix analysis and applications 17.1 (1996): 161-164.

At some point the module will also contain the algorithm proposed in the paper: 

[2] *A fast algorithm for joint diagonalization with non-orthogonal transformations and its application to blind source separation* by Andreas Ziehe, Pavel Laskov, Guido Nolte, and Klaus-Robert Müller published in *The Journal of Machine Learning Research*, 5:777– 800, 2004.

## JDiag Implementations
For the implementation of the AJD in [1] three algorithms are used for comparison.

### `AJD.jdiag_cardoso`

The `AJD.jdiag_cardoso` function is based on [Matlab Code by Cardoso](https://www2.iap.fr/users/cardoso/jointdiag.html). Basic usage with two identity matrices as input:

```julia
using AJD
using LinearAlgebra

# Generate a vector of matrices with real values as input.
test_input = (1.0) * [Matrix(I, 6, 6) , Matrix(I, 6, 6)]

# Calculate diagonlization of the input matrices.
diagonalize(test_input, algorithm="jdiag_cardoso")
```

### `AJD.jdiag_gabrieldernbach`

The second implementation `AJD.jdiag_gabrieldernbach` is based on a [Python implementation by Gabrieldernbach](https://github.com/gabrieldernbach/approximate_joint_diagonalization/) for matrices consisting of real and complex values.

Another version of the function exists which takes matrices with complex values, which uses the paper found in [1] the aformentioned algorithm and loosely the algorithm [Python Code edouardpineau](https://github.com/edouardpineau/Time-Series-ICA-with-SOBI-Jacobi) (also used for the third implementation).

```julia 
using AJD
using LinearAlgebra

# Generate a vector of matrices with real values as input.
test_input = (1.0) * [Matrix(I, 6, 6) , Matrix(I, 6, 6)]

# Calculate diagonlization of the input matrices.
diagonalize(test_input, algorithm="jdiag_gabrieldernbach")
```

### `AJD.jdiag_edourdpineau`

The third implementation is based on the [Python code by Edouardpineau](https://github.com/edouardpineau/Time-Series-ICA-with-SOBI-Jacobi) and is a bit more versatile since it takes a Vector of AbstractMatrices as an input and works for real and complex matrices, as well as hermitian matrices included in the module `PosDefManifold.jl`, which are used in the `Diagonalizations.jl` package too. (Hermitian Matrices are included due to possible integration of other functions defined in the `Diagonalizations.jl` package)

```julia 
using AJD
using LinearAlgebra

# Generate a vector of matrices with real values as input.
test_input = (1.0) * [Matrix(I, 6, 6) , Matrix(I, 6, 6)]

# Calculate diagonlization of the input matrices.
diagonalize(test_input, algorithm="jdiag_edourdpineau")
```

## Minimal Working Example

A minimal working example for all algorithms is demonstrated below. The function `diagonalize()` is the **only** function exported from the module and supports access to all algorithms described above. If supported, a complex matrix is used as input as well.

```julia
using AJD
using LinearAlgebra

# Generate a vector of matrices with real values as input.
testinput = (1.0) * [Matrix(I, 6, 6) , Matrix(I, 6, 6)]

@info "Jdiag", diagonalize(testinput; algorithm = "jdiag")
@info "jdiag_edourdpineau", diagonalize(testinput; algorithm = "jdiag_edourdpineau")
@info "jdiag_cardoso", diagonalize(testinput; algorithm = "jdiag_cardoso")

testinput_imag = [[ 1.0 0.0 1.0*im; 0.0 2.0 0.0; 1.0*im 0.0 1.0],[ 1.0 0.0 1.0*im; 0.0 2.0 0.0; 1.0*im 0.0 1.0]]

@info "jdiag",diagonalize(testinput_imag; algorithm = "jdiag")
@info "jdiag_edourdpineau",diagonalize(testinput_imag; algorithm = "jdiag_edourdpineau")

```

For generating further testdata of real matrices the following function can be used (though the function might only work for `diagonalize(input; algorithm = "jdiag_edourdpineau")`):

```julia
using LinearAlgebra
function random_normal_commuting_matrices(n::Int, m::Int)
    Q, _ = qr(rand(n,n))
    Q = Matrix(Q)
    return [Q*Diagonal(rand(n))*Q' for _ in 1:m]
end

```

## Limitations and Known issue

Due to the different implementations the `algorithm = "jdiag"` and `algorithm = "jdiag_edourdpineau"` give different results in order of approx. 10^-1. However due to machine precision it is unclear how reliable those values really are.