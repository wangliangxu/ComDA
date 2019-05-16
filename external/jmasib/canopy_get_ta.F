! TA , RIB , RB, RD ���v�Z����B
! 99/07/18 �ۍ␪�G ����
!                   rbrd ��Z��
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X

      SUBROUTINE CANOPY_GET_TA ( 
     I   NSTR        , NEND        , 
     I   NTYP        , MON         , 
     I   TMP_CNP     , TMP_SKIN     , TMP_REF       , 
     I   FAC_AG_INV_ms             , XLAI_VEG_ms   , 
     I   FAC_AC_BAR_INV_ms         , 
     I   U2          , RIB_CONST   , 
     I   FAC_CORTMP  , 
     I   Z_REF       , Z0_msx      , R_AIR_CONST_INV  , A_COEF     ,  
     M   ICOUNT      , 
     M   TMP_AIR     , R_AIR_INV   , 
     O   R_AC_BAR    , R_AG        , 
     O   R_AC_BAR_INV, R_AG_INV    , R_SUM_INV   , 
     O   E_AIR_SAT   , E_CNP_SAT   , E_SKIN_SAT     , 
     O   DEC_SAT_DTC , DEG_SAT_DTG , RIB )
!
      USE SIBPRM , ONLY :
     1   IDX , 
     1   ICG
!
      USE SIBCON , ONLY : 
     1   EPSFAC_c 
!
!     use com_teten , only : 
      use com_teten_sib_0109 , only : 
     1   table , dtable 
!
      IMPLICIT NONE
!
!     COMMON /CTETEN/  TABLE(25000)
!     COMMON /DTETEN/ DTABLE(25000)
!     REAL(8)  :: TABLE , DTABLE
!
      INTEGER,INTENT(IN)   :: NSTR
      INTEGER,INTENT(IN)   :: NEND
      INTEGER,INTENT(IN)   :: NTYP(IDX)
      INTEGER,INTENT(IN)   :: MON
!
      REAL(8),INTENT(IN)   :: TMP_CNP (IDX)
      REAL(8),INTENT(IN)   :: TMP_SKIN(IDX)
      REAL(8),INTENT(IN)   :: TMP_REF (IDX)
      REAL(8),INTENT(IN)   :: FAC_AG_INV_ms     (IDX)
      REAL(8),INTENT(IN)   :: XLAI_VEG_ms       (IDX,ICG)
      REAL(8),INTENT(IN)   :: FAC_AC_BAR_INV_ms (IDX)
      REAL(8),INTENT(IN)   :: U2           (IDX)   ! U2
      REAL(8),INTENT(IN)   :: RIB_CONST         (IDX)   
      REAL(8),INTENT(IN)   :: FAC_CORTMP   (IDX)     ! ���x�␳�W�� BPS or ��
      REAL(8),INTENT(IN)   :: R_AIR_CONST_INV(IDX)   ! �������� RA ? 
      REAL(8),INTENT(IN)   :: A_COEF          (IDX)   ! a 
      REAL(8),INTENT(IN)   :: Z_REF           (IDX)   ! = zr ??  
      REAL(8),INTENT(IN)   :: Z0_msx          (IDX)   ! = z0 ??
!
! OUTPUT
!
      REAL(8),INTENT(INOUT) :: TMP_AIR  (IDX)
      REAL(8),INTENT(INOUT) :: R_AIR_INV  (IDX)     ! out only ��?
!
! OUTPUT
!
      REAL(8),INTENT(OUT)   :: R_AC_BAR     (IDX)
      REAL(8),INTENT(OUT)   :: R_AG         (IDX)
      REAL(8),INTENT(OUT)   :: R_AC_BAR_INV (IDX)
      REAL(8),INTENT(OUT)   :: R_AG_INV     (IDX)
      REAL(8),INTENT(OUT)   :: R_SUM_INV    (IDX)  ! 1/(1/rag+1/rac+1/ra)
!
      REAL(8),INTENT(OUT)   :: E_AIR_SAT    (IDX)   ! �L����C�̖O�a���C�� ETA 
      REAL(8),INTENT(OUT)   :: E_CNP_SAT    (IDX)   ! �O�a���C�� ETC 
      REAL(8),INTENT(OUT)   :: E_SKIN_SAT   (IDX)   ! �n�ʁi��܁j�O�a���C��ETG 
      REAL(8),INTENT(OUT)   :: DEC_SAT_DTC (IDX)   ! �O�a���C�� ����
      REAL(8),INTENT(OUT)   :: DEG_SAT_DTG (IDX)   ! �O�a���C�� ����
!
      REAL(8),INTENT(OUT)   :: RIB          (IDX)
!
! WORK
!     
      INTEGER   :: I
      INTEGER   :: ITR_MAX 
      INTEGER   :: ITR
      INTEGER,INTENT(INOUT)   :: ICOUNT
      INTEGER   :: ICHECK       (IDX)
      REAL(8)   :: DIFF
      REAL(8)   :: CTI 
      REAL(8)   :: DIFF_TA_MIN
      REAL(8)   :: TMP_AIR_SAV  (IDX) 
!
      REAL(8)   :: YI
      REAL(8)   :: X
      INTEGER   :: IY
!
      LOGICAL , SAVE :: LFIRST 
!
!
      DATA DIFF_TA_MIN / 2.0D-3 /
!     DATA ITR_MAX       / 2 /
!!    DATA ITR_MAX       / 4 /
      DATA ITR_MAX       / 6 /
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_GET_TA 99/07 POCHAKA'
        LFIRST = .FALSE.
      ENDIF
!
! �E TMP_AIR �̏����l����͂���B
! �E ��������Ƃ� R_AC_BAR �� R_AG ���v�Z
! �E TMP_AIR �����ߒ���
! �E R_AC_BAR,R_AG,R_AIR ������B
!
!  ------------------------
!  >> �C�e���[�V�������� <<
!  ------------------------
!
      ITR    = 0 
      DO 100 I=NSTR,NEND
        ICHECK(I) = 1
 100  CONTINUE  
!
 1000 CONTINUE
!
      ICOUNT = ICOUNT + 1 
      ITR    = ITR    + 1 
      TMP_AIR_SAV(NSTR:NEND) = TMP_AIR(NSTR:NEND)
!
!  ----------------
!  > R_AC_BAR,AG �쐬 <
!  ----------------
!
#ifdef CORRECT 
#else
      IF ( ITR.EQ.1 ) THEN
#endif
        CALL CANOPY_GET_RAC_RAG (
     I  NSTR         , NEND          , ICHECK        ,
     I  NTYP         , MON           , 
     I  TMP_CNP      , TMP_SKIN      , TMP_AIR       , 
     I  FAC_AG_INV_ms, XLAI_VEG_ms   , FAC_AC_BAR_INV_ms  , 
     I  U2           , 
     O  R_AC_BAR     , R_AC_BAR_INV  , R_AG          , R_AG_INV   )
!                       1/RB                          1/RD 
#ifdef CORRECT 
#else
      ENDIF
#endif
!
      DO 3000 I=NSTR,NEND
        IF ( ICHECK(I).EQ.1 ) THEN
!
!  ----------------
!  > TMP_AIR �쐬 <
!  ----------------
!
          TMP_AIR(I) 
     1        =  (   TMP_SKIN (I) * R_AG_INV(I)
     1             + TMP_CNP (I) * ( R_AC_BAR_INV(I)* 2 )
     1             + TMP_REF (I) * R_AIR_INV(I)  * FAC_CORTMP(I) )
     1           / ( R_AG_INV(I) + R_AC_BAR_INV(I)* 2 + R_AIR_INV(I) )
!
!  ---------------------------
!  > RIB... R_AIR_INV �쐬 <
!  ---------------------------
!
          
          RIB (I) = RIB_CONST(I) 
     1              * ( TMP_AIR(I) - TMP_REF (I)*FAC_CORTMP(I))

	    If ( ISNAN(RIB(I)) ) THEN
	       R_AIR_INV (I) = 0
		ELSE    
!
            IF ( RIB(I).GT.0.0D0 ) THEN
              CTI = 1.0D0/(1.0D0+15.0D0*RIB(I)*SQRT(1.0D0+5.0D0*RIB(I)))
            ELSE
              CTI = 1.0D0-15.0D0*RIB(I)/( 1.0D0+75.0D0*A_COEF(I)**2
     1                    *SQRT(-Z_REF(I)/Z0_msx(I)*RIB(I)) )
            END IF
!
            R_AIR_INV (I) = CTI * R_AIR_CONST_INV(I) 
          ENDIF
        ENDIF
 3000 CONTINUE  
!
!  =================
!  >> �����`�F�b�N<<              
!  =================
! 
      DO 4000 I=NSTR,NEND 
        IF ( ICHECK(I).EQ.1 ) THEN
          R_SUM_INV(I) 
     1          = 1 .
     1            / ( R_AG_INV(I) + R_AC_BAR_INV(I)*2 + R_AIR_INV(I) )

          TMP_AIR(I) 
     1          =  (   TMP_SKIN(I) * R_AG_INV(I)
     1               + TMP_CNP (I) * R_AC_BAR_INV(I)*2 
     1               + TMP_REF (I) * R_AIR_INV(I)  * FAC_CORTMP(I) )
     1             * R_SUM_INV(I) 
!
          DIFF = ABS ( TMP_AIR(I) - TMP_AIR_SAV(I) )
          IF ( 
! #ifdef CORRECT
     1          DIFF .LE. DIFF_TA_MIN 
     1          .OR. 
#endif
     1          ITR.EQ.ITR_MAX ) THEN
            ICHECK(I)=0
          END IF
        ENDIF
 4000 CONTINUE
!
#include "noparallel_fixedform"
      DO 4100 I=NSTR,NEND 
        IF ( ICHECK(I).EQ.1 )   GOTO 1000
 4100 CONTINUE
!
! ========================
! >> ���ʂ��g���Č㏈�� <<
! ========================
!  ���łɃL���m�s�[���x�A�n�ʉ��x�ɂ��Ă�... 
!
      DO 5000 I=NSTR,NEND 
#ifdef SIB_DEBUG
        IF (      TMP_SKIN(I) .LT. 160 .OR. TMP_SKIN(I) .GT. 350 
     1       .OR. TMP_CNP (I) .LT. 160 .OR. TMP_CNP (I) .GT. 350 
     1       .OR. TMP_REF (I) .LT. 160 .OR. TMP_REF (I) .GT. 350 ) THEN 
!
          WRITE(6,*) 'CANOPY_GET_TA ERROR TMP_AIR' , I , TMP_AIR(I)
          WRITE(6,*) ' skin cnp ref  ' , 
     1                TMP_SKIN(I) ,
     1                TMP_CNP (I) ,
     1                TMP_REF (I) 
!
          STOP 999
!
        ELSEIF 
     1     (      TMP_SKIN(I) .LT. 180 .OR. TMP_SKIN(I) .GT. 330 
     1       .OR. TMP_CNP (I) .LT. 180 .OR. TMP_CNP (I) .GT. 330 
     1       .OR. TMP_REF (I) .LT. 180 .OR. TMP_REF (I) .GT. 330 ) THEN 
!
          WRITE(6,*) 'CANOPY_GET_TA WARNING TMP_AIR' , I , TMP_AIR(I)
          WRITE(6,*) ' skin cnp ref  ' , 
     1                TMP_SKIN(I) ,
     1                TMP_CNP (I) ,
     1                TMP_REF (I) 
        ENDIF
#endif 
!
        YI = (TMP_AIR(I)-123.2D0)*100.0D0
        IY = YI
        IY = MAX ( IY, 1 )
        IY = MIN ( IY, 24999 )
        X = YI - IY
        E_AIR_SAT(I) = ((1.0D0-X)*TABLE(IY)+X*TABLE(IY+1))/EPSFAC_c
! 
        YI = (TMP_CNP(I)-123.2D0)*100.0D0
        IY = YI
        IY = MAX( IY, 1 )
        IY = MIN( IY, 24999 )
        X = YI - IY
        E_CNP_SAT   (I)=((1.0D0-X)* TABLE(IY)+X* TABLE(IY+1))/EPSFAC_c
        DEC_SAT_DTC (I)=((1.0D0-X)*DTABLE(IY)+X*DTABLE(IY+1))/EPSFAC_c
!
        YI = (TMP_SKIN(I)-123.2D0)*100.0D0
        IY = YI
        IY = MAX( IY, 1 )
        IY = MIN( IY, 24999 )
        X = YI - IY
        E_SKIN_SAT  (I)=((1.0D0-X)* TABLE(IY)+X* TABLE(IY+1))/EPSFAC_c
        DEG_SAT_DTG (I)=((1.0D0-X)*DTABLE(IY)+X*DTABLE(IY+1))/EPSFAC_c
!
 5000 CONTINUE   

!
      RETURN
      END
!===================================================================
      SUBROUTINE CANOPY_GET_RAC_RAG (
     I  NSTR         , NEND          , ICHECK        ,
     I  NTYP         , MON           , 
     I  TMP_CNP      , TMP_SKIN       , TMP_AIR       , 
     I  FAC_AG_INV_ms, XLAI_VEG_ms   , FAC_AC_BAR_INV_ms    , 
     I  U2           , 
     O  R_AC_BAR     , R_AC_BAR_INV  , R_AG        , R_AG_INV   )
!
! �v���O���}�[�ւ̒��ӁB
!   �E�ᖳ���E��L����킸�Ɏg����B
!   �ERB �͋t�� RB_INV �̕�����������B��ŕK�v�Ȃ̂͂ǂ���?
!
      USE SIBPRM , ONLY : 
     1   IDX   , 
     1   ICG   , 
     1   IMON  , 
     1   ITYP  
!
      USE SIBVEG , ONLY : 
     1           Z2_mo                    ! �L���m�s�[��[���� (ITYP,IMON)

!
      IMPLICIT NONE
!
! OUTPUT
!
      REAL(8),INTENT(OUT)  :: R_AC_BAR     (IDX) 
!                                            !�L���ƃL����ԊԂ̒�R rb s/m
      REAL(8),INTENT(OUT)  :: R_AC_BAR_INV (IDX) ! ����t��
      REAL(8),INTENT(OUT)  :: R_AG     (IDX) !�n�ʂƃL����ԊԂ̒�R rg s/m
      REAL(8),INTENT(OUT)  :: R_AG_INV (IDX) !����t��
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NSTR
      INTEGER,INTENT(IN)   :: NEND
      INTEGER,INTENT(IN)   :: ICHECK   (IDX)
!
      INTEGER,INTENT(IN)   :: NTYP(IDX)
      INTEGER,INTENT(IN)   :: MON
!
      REAL(8),INTENT(IN)   :: TMP_AIR  (IDX)   ! �L���m�s�[��ԉ��x
      REAL(8),INTENT(IN)   :: U2(IDX)   ! �L���m�s�[�g�b�v�ł̕��� m/s 
!
!  ( RB �v�Z�p )
      REAL(8),INTENT(IN)   :: TMP_CNP (IDX)    ! �L���m�s�[���x
      REAL(8),INTENT(IN)   :: XLAI_VEG_ms (IDX,ICG)! �t�ʐώw��
      REAL(8),INTENT(IN)   :: FAC_AC_BAR_INV_ms (IDX) 
!                                       ! �L���ƃL����ԊԂ̒�R�萔 Bc
!
!  ( RD �v�Z�p )
      REAL(8),INTENT(IN)   :: TMP_SKIN (IDX)    ! �n�ʉ��x              K 
      REAL(8),INTENT(IN)   :: FAC_AG_INV_ms (IDX) 
!                                       ! �n�ʁE�L���ԋ�C�͊w��R�萔Dg
!
! WORK
!
      REAL(8)     :: FAC_C 
      REAL(8)     :: FAC_G1
      REAL(8)     :: FAC_G2
      REAL(8)     :: DIFF
      REAL(8)     :: TMP_DIFF
      INTEGER     :: I  
!
      REAL(8),SAVE  :: FACTC 
      REAL(8),SAVE  :: FACTG 
      REAL(8),SAVE  :: ZERO
!
      LOGICAL,SAVE  :: LFIRST 
!
      DATA FACTC / 2.3761D-3 /         ! 1/(890*0.05**(1/4))
      DATA FACTG / 88.29D0   /  
      DATA ZERO  / 0.0D0     /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CNOPY_GET_RAC_RAG 99/07 POCHAKA'
        LFIRST = .FALSE.
      ENDIF
!
      DO 100 I=NSTR,NEND
!
      IF ( ICHECK(I).EQ.1 ) THEN
!
!  ----------------
!  >> RAC �̌v�Z << 
!  ----------------
!       �ꖇ���Ƃ́A�t�ƃL���m�s�[��Ԃ̊Ԃ̒�R���A�S�i�q�ɓn��ϕ��B
!
!      �i�L���m�s�[�̂Ȃ��������܂ށj�i�q���ϒl�ł��邱�Ƃɒ��ӁB
!       FAC �͍����� 1-2-102 �̉E�ӑ�ꍀ
!
        DIFF = TMP_CNP(I) - TMP_AIR(I)   
        TMP_DIFF = MAX ( DIFF , ZERO ) + 0.1  
!
        FAC_C		= XLAI_VEG_ms(I,1) * SQRT(MAX(0.0, SQRT(TMP_DIFF))) 
     1                                      * FACTC
!
        R_AC_BAR_INV(I)  =  SQRT(MAX(U2(I), 0.0)) * FAC_AC_BAR_INV_ms(I) 
     1                       + FAC_C
!          ���ӁB���M�p�Ɏg���Ƃ��́A���ʂ���o��̂ŁA��R�͂��̔����ɂȂ� �B
        R_AC_BAR    (I)  = 1. / R_AC_BAR_INV(I)    
!
!  ----------------
!  >> RAG �̌v�Z << 
!  ----------------
!    FAC_G1 �� ���� �� 1-2-104 �̒����ʂ̒��g
!
        DIFF     = TMP_SKIN(I) - TMP_AIR(I)   
        TMP_DIFF = MAX ( DIFF , ZERO ) + 0.1  
!
        FAC_G1 =  1.0D0 
     1           + FACTG * TMP_DIFF 
     1               / ( TMP_SKIN(I) * U2(I)**2  ) 
     1               * Z2_mo (NTYP(I),MON) 
!
        FAC_G2 = SQRT ( MAX(FAC_G1,0.0) ) 
!
        R_AG_INV(I) =  U2(I) * FAC_G2 * FAC_AG_INV_ms(I)  
        R_AG    (I) =  1. / R_AG_INV(I) 
!
      ENDIF
  100 CONTINUE
!
      RETURN
      END