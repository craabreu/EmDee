!   This file is part of EmDee.
!
!    EmDee is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    EmDee is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with EmDee. If not, see <http://www.gnu.org/licenses/>.
!
!    Author: Charlles R. A. Abreu (abreu@eq.ufrj.br)
!            Applied Thermodynamics and Molecular Simulation
!            Federal University of Rio de Janeiro, Brazil

module pair_softcore_cut_module

use global
use pairModelClass
use pair_lj_cut_module

real(rb), parameter :: alpha      = 0.5_rb, &
                       exponent_n = 1.0_rb, &
                       exponent_p = 1.0_rb

!> Abstract class for pair model softcore_cut
!! NOTE: all model parameters must be declared together as real(rb) in the first line
type, extends(cPairModel) :: pair_softcore_cut
  real(rb) :: epsilon, sigma, lambda
  real(rb) :: prefactor, invSigSq, sig6, shift
  contains
    procedure :: setup => pair_softcore_cut_setup
    procedure :: compute => pair_softcore_cut_compute
    procedure :: mix => pair_softcore_cut_mix
end type pair_softcore_cut

contains

!---------------------------------------------------------------------------------------------------

  subroutine pair_softcore_cut_setup( model, params )
    class(pair_softcore_cut), intent(inout) :: model
    real(rb),       intent(in)    :: params(:)

    ! Model name:
    model%name = "softcore_cut"

    ! Model parameters:
    model%epsilon = params(1)
    model%sigma = params(2)
    model%lambda = params(3)

    ! Pre-computed quantities:
    model%prefactor = 4.0_rb * model%epsilon * model%lambda**exponent_n
    model%invSigSq = one/model%sigma**2
    model%sig6 = model%sigma**6
    model%shift = alpha*(one - model%lambda)**exponent_p

  end subroutine pair_softcore_cut_setup

!---------------------------------------------------------------------------------------------------

  subroutine pair_softcore_cut_compute( model, Eij, Wij, invR2, Qi, Qj )
    class(pair_softcore_cut), intent(in)  :: model
    real(rb),       intent(out) :: Eij, Wij
    real(rb),       intent(in)  :: invR2, Qi, Qj

    include "compute_pair_softcore_cut.f90"

  end subroutine pair_softcore_cut_compute

!---------------------------------------------------------------------------------------------------

  function pair_softcore_cut_mix( this, other ) result( mixed )
    class(pair_softcore_cut),    intent(in) :: this
    class(cPairModel), intent(in) :: other
    class(cPairModel), pointer :: mixed

    select type (other)
      class is (pair_softcore_cut)
        allocate(pair_softcore_cut :: mixed)
        call mixed % setup( [sqrt(this%epsilon*other%epsilon), &
                             half*(this%sigma + other%sigma),  &
                             sqrt(this%lambda*other%lambda)    ] )
      class is (pair_lj_cut)
        allocate(pair_softcore_cut :: mixed)
        call mixed % setup( [sqrt(this%epsilon*other%epsilon), &
                             half*(this%sigma + other%sigma),  &
                             this%lambda                       ] )
      class default
        mixed => null()
    end select

  end function pair_softcore_cut_mix

!---------------------------------------------------------------------------------------------------

end module pair_softcore_cut_module