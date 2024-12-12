module AJD
using LinearAlgebra
using PosDefManifold
# Write your package code here.
function Is_Commuting(A::AbstractMatrix, B::AbstractMatrix)
    return A*B == B*A
end

function Is_Same_size(A::AbstractMatrix, B::AbstractMatrix)
    return size(A) == size(B)
end

function Is_Symmetric(A::AbstractMatrix)
    return size(A,1) == size(A,2)
end

function get_non_Diag_elements(A::AbstractMatrix)
    #Code found under: https://discourse.julialang.org/t/off-diagonal-elements-of-matrix/41169/4
    #best method regarding compilation time found so far
        row, column = size(A)
        non_diag_elements_vector = [A[index_row, index_column] for index_row = 1:row, index_column = 1:column if index_row != index_column]
        return non_diag_elements_vector
end
function Jacobi_Rotation(G::Matrix)

    Eigenvalues,Eigenvector = eigen(G) #sorted by highest value last

    max_eigenvector = Eigenvector[:,end] #get the eigenvector of the corresponding highest eigenvalue
    max_eigenvector = sign(max_eigenvector[1])*max_eigenvector #why is that? i don't know why i need to do that but the code says so?
    
    x = max_eigenvector[1]
    y = max_eigenvector[2]
    z = max_eigenvector[3]

    r = sqrt(x^2+y^2+z^2)

    c = sqrt((x+r)/2*r)

    s = (y - z*im)/(sqrt(2*r(x+r)))
    R = [c conj(s); -s conj(c)]
    return R

end
function convert_Hermitian(A)
    elements = size(A)[1]
    row, columns = size(A[1])
    Array = zeros(row,columns,elements)
    for element in elements
        Array[:,:,element] = A[element]
    end
    return Array
end
function JADE(A::AbstractArray;threshold = 10e-18, max_iter = 1000)
    #ToDo: Make A an Hermitian Matrix from LinearAlgebra.jl
    
    #A concatenate in third dimension by  A =[[1 2; 1 2];;;[2 3; 4 5]]
    #only works for Real Matrices of A but not complex
    A = Float64.(A) #if the Array isn't already of Float64
    
    rows, columns, k = size(A)

    #initialize the apporximate joint eigenvecotrs as described in Cardoso
    V = (1.0)*I(rows)+zeros(rows, columns) #needs to be added otherwise we cannot manipulate the non diag. elements of V
    
    iteration_step = 0

    active = true #flag if threshold is reached
    while iteration_step >= max_iter || active == true
   
        active = false

        for row = 1:rows
            for column = 2:columns
                h_diag = A[row,row,:] - A[column,column,:] #first entry of h
                h_non_diag = A[row,column,:] + A[column,row,:] #second entry of h
                
                ton = dot(h_diag,h_diag) - dot(h_non_diag,h_non_diag)
                toff = 2*dot(h_diag,h_non_diag)
                θ = 0.5*atan(toff, ton + sqrt(ton*ton + toff * toff))

                c = cos(θ)
                s = sin(θ)
                R = [ c s; -s c]
                active = active || abs(s) > threshold
                if abs(s) > threshold
                    pair = [row, column]
                
                    for n = 1:k
                        A[:,pair,n] = transpose(R*transpose(A[:,pair,n]))
                        A[pair,:,n] = R*A[pair,:,n]
                    end
                    V[:,pair] = transpose(R*transpose(V[:,pair]))
                end
                
            end
        end 
        iteration_step += 1
    end
    
    return  A,V

end

export Is_Commuting
export Is_Same_size
export Is_Symmetric
export get_non_Diag_elements
export Jacobi_Rotation
export JADE
export convert_Hermitian
end
