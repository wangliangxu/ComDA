! �L���m�s�[�v�Z�ɕK�v�ȁA��C�Q�ƃ��x���̏������B
! 99/07/25 �ۍ␪�G �V�K�쐬
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE CANOPY_ATMOS (
     I   NMAX          , 
     I   P_SFC         , TMP_REF       ,  Q_REF     , 
     O   RHO_AIR       , RHO_CP   , 
     O   E_REF         , 
     O   FAC_EVP       , FAC_EVP_2 )
!
! ���ӁB
!   ��L�薳���Ɋ֌W�Ȃ��ʂ̌v�Z
!
!   fac_evp �ɂ��āB
!     ��Ŏg���Ƃ��� �����C�� E_*  �Ƃ̂����Z�̌`�Ŏg���B
!     E_* �̒P�ʂ��AP_SFC �̒P�ʂ� HPa = �ł���B
!
! �����C�� e ( �P�� HPa ) �̕]���ɂ́A
!    e �` pq/�� �Ƃ����ߎ�����p���Ă���
!
      USE SIBPRM , ONLY :
     1   IDX
!
      USE SIBCON , ONLY : 
     1   R_DRY_INV_c                ,  ! ������C�C�̒萔
     1   HL_WTR_c                   ,  ! 
     1   CP_AIR_c                   ,  ! 
     1   EPSFAC_c                      ! 0.622(������)=���q�ʔ� H2O/����
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NMAX
!
      REAL(8),INTENT(IN)    :: P_SFC    (IDX)
      REAL(8),INTENT(IN)    :: TMP_REF  (IDX)
      REAL(8),INTENT(IN)    :: Q_REF    (IDX)
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)   :: RHO_AIR   (IDX)   ! 
      REAL(8),INTENT(OUT)   :: RHO_CP    (IDX)   ! 
      REAL(8),INTENT(OUT)   :: E_REF   (IDX)     ! 
      REAL(8),INTENT(OUT)   :: FAC_EVP   (IDX)   ! �σ�/P_s
      REAL(8),INTENT(OUT)   :: FAC_EVP_2 (IDX)   ! P_s/��   e �` FAC_EVP_2 q
!
      INTEGER    :: I
!  
      LOGICAL,SAVE ::  LFIRST
!
      DATA LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN 
        WRITE(6,*) 'CANOPY_ATMOS 99/07 POCHKA' 
        LFIRST = .FALSE. 
      ENDIF
!
      DO 1000 I=1,NMAX
        RHO_AIR  (I) = P_SFC(I) * 100.0D0 * R_DRY_INV_c / TMP_REF(I)  
        RHO_CP   (I) = RHO_AIR(I) * CP_AIR_c
        FAC_EVP  (I) = RHO_AIR(I) * EPSFAC_c / P_SFC(I)
        FAC_EVP_2(I) = P_SFC(I) / EPSFAC_c 
        E_REF    (I) = FAC_EVP_2(I) * Q_REF(I)  
 1000 CONTINUE
!
      RETURN
      END