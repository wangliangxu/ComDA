! �n�ʓ����ł̉��x�̎������Ă�B
! 99/06/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE SOIL_HFLUX_IMPLICIT_EQSET (
     I  NSTR       , NEND          , 
#ifdef MONYOS
     I  INSFLAG    ,
#endif
     I  CVR_SorN_INV , 
     I  TMP_SOIL   , TMP_SOIL4     , 
     I  PHASE_SOIL , 
     I  CAP_SOIL   , 
     I  HDF_SOIL_H , 
     I  ENG_BUCKET_TOP_H , 
     I  DELT_SOIL  , DELT_SOIL_INV , 
     O  SIB_MTX_SOIL  , HFLUX_H    )

!
!    ����  
!      �E��Ȃ��̈�A�Ⴀ��̈�Ƃ��A������g���B
!      �E�㑤�͔M�t���b�N�X���^�����Ă���B 
!      �E���t���b�N�X�͂܂������Ă��Ȃ��B
!  
!        D1    1  
!        D2    2  
!        D3    3  
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    IDP     
!
      USE SIBCON , ONLY :
     1    DELT_FAC_SOIL_c,  itune_soilfluxbottom_c 

!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB , ICN, ICS, INN, INS, INA, 
     1                       IMONIT_LEVEL , IMONIT_ALL,
     1                       IMONIT_FLUX_COMMON,
     1                       IMONIT_ALMA 
#endif
!
      IMPLICIT NONE 
!
! INPUT 
      INTEGER,INTENT(IN)    :: NSTR               ! �J�n�ʒu	
      INTEGER,INTENT(IN)    :: NEND               ! �I���ʒu 
      REAL(8),INTENT(IN)    :: DELT_SOIL          ! SIB�p�C���v���V�b�g����
      REAL(8),INTENT(IN)    :: DELT_SOIL_INV      ! SIB�p�C���v���V�b�g����
#ifdef MONYOS
      INTEGER,INTENT(IN)    :: INSFLAG            ! SIB�p�C���v���V�b�g����
#endif
!
      REAL(8),INTENT(IN)    :: CVR_SorN_INV (IDX)
!
      REAL(8),INTENT(IN)    :: TMP_SOIL   (IDX,IDP)   ! �y�뉷�x
      REAL(8),INTENT(IN)    :: TMP_SOIL4  (IDX) 
      REAL(8),INTENT(IN)    :: CAP_SOIL   (IDX,IDP)   ! �y��M�e��
      REAL(8),INTENT(IN)    :: HDF_SOIL_H (IDX,IDP)   ! �y 1-2,2-3 �ԔM�W��
      REAL(8),INTENT(IN)    :: ENG_BUCKET_TOP_H (IDX)   ! �n�ʏ�[�����M��
!                                                     !     * DELT_SOIL ��
      REAL(8),INTENT(IN)    :: PHASE_SOIL (IDX,IDP)   ! ��x�Ȃ� 0 , �� 1  
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)   :: SIB_MTX_SOIL   (IDX,IDP,IDP+1) 
!
! WORK
      INTEGER               :: I
      REAL(8)               :: DELT_TMP
      REAL(8),intent(out)   :: HFLUX_H (IDX,0:IDP)    ! �G�N�X�v���V�b�g flux
!
#ifdef MONYOS
      CHARACTER(7)      :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0 
#endif
!
      LOGICAL,SAVE :: LFIRST
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN 
        WRITE(6,*) 'SOIL_HFLUX_EQSET 99/08 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DELT_TMP = DELT_SOIL * DELT_FAC_SOIL_c
!
!  -----------------------------
!  �t���b�N�X�i�G�N�X�v���V�b�g�j
!  -----------------------------
!
      DO I=NSTR,NEND
        HFLUX_H(I,0) = ENG_BUCKET_TOP_H(I)*DELT_SOIL_INV*CVR_SorN_INV(I)
        HFLUX_H(I,1) = HDF_SOIL_H(I,1)*( TMP_SOIL(I,1) - TMP_SOIL(I,2) )      
        HFLUX_H(I,2) = HDF_SOIL_H(I,2)*( TMP_SOIL(I,2) - TMP_SOIL(I,3) )      
        HFLUX_H(I,3) = HDF_SOIL_H(I,3)*( TMP_SOIL(I,3) - TMP_SOIL4(I)  )      
     1                 * itune_soilfluxbottom_c 
      ENDDO
!
      call reset ( SIB_MTX_SOIL , IDX*IDP*(IDP+1) )
!
!  ---------------------------------------------------
!  �y����w�̎� 
!  ---------------------------------------------------
!
      DO 1000 I=NSTR    ,NEND    
        SIB_MTX_SOIL(I,1,1)                         ! �y����w
     1   =   CAP_SOIL(I,1) 
     1     + HDF_SOIL_H(I,1) * DELT_TMP                ! �y����w��
     1         * PHASE_SOIL(I,1)
!
        SIB_MTX_SOIL(I,1,2)                         ! �y����w
     1   = - HDF_SOIL_H(I,1) * DELT_TMP 
     1         * PHASE_SOIL(I,2)
!
        SIB_MTX_SOIL(I,1,4)                                  ! ����
!    1   =  ENG_BUCKET_TOP_H(I)*DELT_SOIL_INV*CVR_SorN_INV(I)
     1   =  HFLUX_H(I,0) - HFLUX_H(I,1)
 1000 CONTINUE         
!
!  ---------------------------------------------------
!  �y����w�̎� 
!  ---------------------------------------------------
!
      DO 2000 I=NSTR    ,NEND    
!
        SIB_MTX_SOIL(I,2,1)                        ! �y����w   
     1    = - HDF_SOIL_H(I,1) * DELT_TMP 
     1                          * PHASE_SOIL(I,1)
!
        SIB_MTX_SOIL(I,2,2)                        ! �y����w 
     1     =   CAP_SOIL  (I,2) 
     1       + HDF_SOIL_H(I,1) * DELT_TMP             ! �y����w��
     1                         * PHASE_SOIL(I,2)
     1       + HDF_SOIL_H(I,2) * DELT_TMP               ! �y���O�w��
     1                         * PHASE_SOIL(I,2)
!
        SIB_MTX_SOIL(I,2,3)                       ! �y���O�w
     1     = - HDF_SOIL_H(I,2) * DELT_TMP
     1                         * PHASE_SOIL(I,3)
!
        SIB_MTX_SOIL(I,2,4) =                     ! ����
     1      +  HFLUX_H(I,1) -  HFLUX_H(I,2) 
 2000 CONTINUE         
!
!  ---------------------------------------------------
!  �y���O�w�̎� 
!  ---------------------------------------------------
!
      DO 3000 I=NSTR    ,NEND    
!
        SIB_MTX_SOIL (I,3,2)                       ! �y����w
     1     = - HDF_SOIL_H(I,2) * DELT_TMP
     1                         * PHASE_SOIL(I,2)
!
        SIB_MTX_SOIL (I,3,3)                       ! �y���O�w
     1     =   CAP_SOIL  (I,3) 
     1       + HDF_SOIL_H(I,2) * DELT_TMP
     1                         * PHASE_SOIL(I,3)
!
        SIB_MTX_SOIL (I,3,4)                       ! ����
     1     = HFLUX_H(I,2) -  HFLUX_H(I,3) 
 3000 CONTINUE         
!
! ================
! >> �ڍ׃��j�^ <<
! ================
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
        IF ( INSFLAG.EQ.0 ) THEN
          CMARK  = 'FLG0'
          CALL MONIT_SIB ( CMARK, ENG_BUCKET_TOP_H,INN, ONE , ONE)
        ELSE
          CMARK  = 'FLG0'
          CALL MONIT_SIB ( CMARK, ENG_BUCKET_TOP_H,INS, ONE , ONE)
        ENDIF
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
        IF ( INSFLAG.EQ.0 ) THEN
          CMARK  = 'HFLBLN'
          CALL MONIT_SIB ( CMARK, ENG_BUCKET_TOP_H,INN, ONE , ONE)
          CMARK  = 'HFLN12'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,1),    ICN, DELT_SOIL,ONE)  
          CMARK  = 'HFLN23'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,2),    ICN, DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'HFLBLW'
          CALL MONIT_SIB ( CMARK, ENG_BUCKET_TOP_H, INS, ONE , ONE)
          CMARK  = 'HFLS12'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,1),     ICS, DELT_SOIL,ONE)  
          CMARK  = 'HFLS23'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,2),     ICS, DELT_SOIL,ONE)  
        ENDIF
!
      ENDIF
!
!* ALMA 
      IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN
        CMARK  = 'A_GH'
        IF ( INSFLAG.EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK, ENG_BUCKET_TOP_H,INN, ONE , ONE)
        ELSE
          CALL MONIT_SIB ( CMARK, ENG_BUCKET_TOP_H,INS, ONE , ONE)
        ENDIF
      ENDIF
#endif
!
      RETURN
      END
!===============================================================
! �n���̕�����������
      SUBROUTINE SOIL_HFLUX_IMPLICIT_EQSLV (
     I  NSTR  , NEND  , 
     M  SMTX      ) 
!
!     ��Ȃ��A�Ⴀ��A���ꂼ��ŌĂ΂��B
!
!     D1  1
!     D2  2
!     D3  3
!
      USE SIBPRM , ONLY : 
     1    IDX      
!
      IMPLICIT NONE 
!
! INPUT
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
!
! INOUT
!
      REAL(8),INTENT(INOUT) :: SMTX(IDX,3,4) 
!
! WORK
      INTEGER               :: I
      REAL(8)               :: A22I 
      REAL(8)               :: A33I 
!
      LOGICAL,SAVE :: LFIRST
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN 
        WRITE(6,*) 'SOIL_HFLUX_EQSLV 99/08 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DO 1000 I=NSTR,NEND
!
!a11  a12       a14
!a21  a22  a23  a24
!     a32  a33  a34
!
        A33I = 1. / SMTX(I,3,3) 
        SMTX(I,3,2) = SMTX(I,3,2) * A33I  
        SMTX(I,3,4) = SMTX(I,3,4) * A33I  
!       SMTX(I,3,3) = 1. 
!
        SMTX(I,2,2) = SMTX(I,2,2) - SMTX(I,2,3) * SMTX(I,3,2) 
        SMTX(I,2,4) = SMTX(I,2,4) - SMTX(I,2,3) * SMTX(I,3,4) 
!       SMTX(I,2,3) = 0. 
!
!a11  a12       a14
!a21  a22*  0*  a24*
!     a32*  1*  a34*
!
        A22I = 1. / SMTX(I,2,2) 
        SMTX(I,2,1) = SMTX(I,2,1) * A22I  
        SMTX(I,2,4) = SMTX(I,2,4) * A22I  
!       SMTX(I,2,2) = 1. 
!
        SMTX(I,1,1) = SMTX(I,1,1) - SMTX(I,1,2) * SMTX(I,2,1) 
        SMTX(I,1,4) = SMTX(I,1,4) - SMTX(I,1,2) * SMTX(I,2,4) 
!       SMTX(I,1,2) = 0. 
!
!a11*  0*       a14*
!a21*  1*       a24*
!     a32   1   a34
!
        SMTX(I,1,4) = SMTX(I,1,4) / SMTX(I,1,1)
!       SMTX(I,1,1) = 1. 
!
! 1*            a14*
!a21   1        a24
!     a32   1   a34
!
        SMTX(I,2,4) = SMTX(I,2,4) - SMTX(I,2,1) * SMTX(I,1,4)  
!       SMTX(I,2,1) = 0. 
        SMTX(I,3,4) = SMTX(I,3,4) - SMTX(I,3,2) * SMTX(I,2,4)  
!       SMTX(I,3,2) = 0. 
 1000 CONTINUE
!
      RETURN
      END
!===============================================================
! �y�뒆�̔M�t���b�N�X���� �i���̈ړ����l�����Ȃ����_�j
! 99/07/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE SOIL_HFLUX_IMPLICIT_CONV (
     I  NSTR            , NEND            , 
#ifdef MONYOS
     I  INSFLAG         ,
#endif
     I  SIB_MTX_SOIL    , 
     I  HDF_SOIL_H      , 
     I  PHASE_SOIL      , 
     I  DELT_SOIL       , 
     M  HFLUX_H         ,
     O  HEAT_CONV    )  
!
      USE SIBPRM , ONLY :
     1    IDX   ,
     1    IDP  
!
      USE SIBCON , ONLY :
     1   DELT_FAC_SOIL_c
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB , ICN, ICS, INN, INS, 
     1                       IMONIT_LEVEL , IMONIT_ALL,
     1                       IMONIT_FLUX_COMMON 
#endif
!
      IMPLICIT NONE
!
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
      REAL(8),INTENT(IN)    :: SIB_MTX_SOIL     (IDX,IDP,IDP+1)
      REAL(8),INTENT(IN)    :: HDF_SOIL_H       (IDX,IDP-1)
      REAL(8),INTENT(IN)    :: PHASE_SOIL       (IDX,IDP)
!
      REAL(8),INTENT(IN)    :: DELT_SOIL                
!
#ifdef MONYOS
      INTEGER,INTENT(IN)    :: INSFLAG            ! SIB�p�C���v���V�b�g����
#endif
!
! INOUT
!   
      REAL(8),INTENT(INOUT) :: HFLUX_H   (IDX,0:IDP) ! �M�t���b�N�X
      REAL(8),INTENT(OUT)   :: HEAT_CONV (IDX,IDP+1) ! �M�t���b�N�X����
!
! WORK
!
      INTEGER   :: I
      REAL(8)   :: DELT_TMP
!      REAL(8)   :: HFLX_COR_12 (IDX)
!      REAL(8)   :: HFLX_COR_23 (IDX)
!      REAL(8)   :: HFLX_COR_34 
!
#ifdef MONYOS
      CHARACTER(7)      :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0 
!     REAL(8)           :: WORK(IDX) 
#endif
!
      LOGICAL,SAVE :: LFIRST
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN 
        WRITE(6,*) 'SOIL_HFLUX_CONV 99/08 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
! �G�N�X�v���V�b�g�]���ɁA�C���v���V�b�g����������B
!
      DELT_TMP = DELT_SOIL * DELT_FAC_SOIL_c
!
      DO 1000 I=NSTR,NEND
!
        HFLUX_H(I,1) = HFLUX_H(I,1) +  
     1     HDF_SOIL_H(I,1) * DELT_TMP
     1        * (   SIB_MTX_SOIL(I,1,4) * PHASE_SOIL(I,1) 
     1            - SIB_MTX_SOIL(I,2,4) * PHASE_SOIL(I,2)     )
!
        HFLUX_H(I,2) = HFLUX_H(I,2) +  
     1     HDF_SOIL_H(I,2) * DELT_TMP
     1        * (   SIB_MTX_SOIL(I,2,4) * PHASE_SOIL(I,2) 
     1            - SIB_MTX_SOIL(I,3,4) * PHASE_SOIL(I,3)     )
!
!       HFLUX_H(I,3) = HFLUX_H(I,3)   
!
        HEAT_CONV(I,1) = HFLUX_H(I,0) - HFLUX_H(I,1)
        HEAT_CONV(I,2) = HFLUX_H(I,1) - HFLUX_H(I,2)
        HEAT_CONV(I,3) = HFLUX_H(I,2) - HFLUX_H(I,3)
        HEAT_CONV(I,4) = HFLUX_H(I,3) 
 1000 CONTINUE   
!
! ================
! >> �ڍ׃��j�^ <<
! ================
!
#ifdef MONYOS
!
! �i�q���Ϗo��
!
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!
        IF ( INSFLAG.EQ.0) THEN
          CMARK  = 'FLG1'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,1), ICN, DELT_SOIL, ONE)  
          CMARK  = 'FLG2'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,2), ICN, DELT_SOIL, ONE)  
          CMARK  = 'FLG3'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,3), ICN, DELT_SOIL, ONE)  
        ELSE
          CMARK  = 'FLG1'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,1), ICS, DELT_SOIL, ONE)  
          CMARK  = 'FLG2'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,2), ICS, DELT_SOIL, ONE)  
          CMARK  = 'FLG3'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,3), ICS, DELT_SOIL, ONE)  
        ENDIF
      ENDIF
!
! �̈�ʏo��
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
        IF ( INSFLAG.EQ.0) THEN
          CMARK  = 'HFLN12F'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,1), ICN, DELT_SOIL, ONE)  
          CMARK  = 'HFLN23F'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,2), ICN, DELT_SOIL, ONE)  
          CMARK  = 'HFLN34F'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,3), ICN, DELT_SOIL,ONE)  
        ELSE
          CMARK  = 'HFLS12F'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,1), ICS, DELT_SOIL, ONE)  
          CMARK  = 'HFLS23F'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,2), ICS, DELT_SOIL, ONE)  
          CMARK  = 'HFLS34F'
          CALL MONIT_SIB ( CMARK, HFLUX_H(1,3), ICS, DELT_SOIL, ONE)  
        ENDIF
      ENDIF
#endif
!
      RETURN
      END
!===============================================================
      SUBROUTINE MR_SOIL_HFLUX_IMPLICIT 
!
! soil_hflux_eqset �ŏo�͂���f�o�b�O�p�ϐ��̓o�^���
!
      USE SIB_MONIT, ONLY :  IMONIT_LEVEL , IMONIT_ALL,
     1                       IMONIT_FLUX_COMMON , IMONIT_ALMA
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
!
      LOGICAL,SAVE ::  LFIRST 
!
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MR_SOIL_HFLUX_IMPLICIT 99/09 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
!  �M�t���b�N�X  HFLXG01,HFLXG12,HFLXG23
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!
!  �y�뒆�M�`��
!
        CMARK  = 'FLG0'
        CTITLE = 'Heat Flux soil surface - soil1'
        CUNIT  = 'W/m**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
        CMARK  = 'FLG1'
        CTITLE = 'Heat Flux soil1 - soil2'
        CUNIT  = 'W/m**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
        CMARK  = 'FLG2'
        CTITLE = 'Heat Flux soil2 - soil3'
        CUNIT  = 'W/m**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
        CMARK  = 'FLG3'
        CTITLE = 'Heat Flux soil3 - bottom'
        CUNIT  = 'W/m**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
      CMARK  = 'HFLBLN'
      CTITLE = 'HEAT FLUX TO SOIL 1 NOS explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLN12'
      CTITLE = 'HEAT FLUX FROM SOIL 1 TO SOIL 2 NOS explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLN23'
      CTITLE = 'HEAT FLUX FROM SOIL 2 TO SOIL 3 NOS explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLBLW'
      CTITLE = 'HEAT FLUX TO SOIL 1 SNW explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLS12'
      CTITLE = 'HEAT FLUX FROM SOIL 1 TO SOIL 2 SNW explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLS23'
      CTITLE = 'HEAT FLUX FROM SOIL 2 TO SOIL 3 SNW explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  �M�t���b�N�X�␳��
!
      CMARK  = 'HFLN12F'
      CTITLE = 'HEAT FLUX FROM SOIL 1 TO SOIL 2 NOS after CORRECT'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLN23F'
      CTITLE = 'HEAT FLUX FROM SOIL 2 TO SOIL 3 NOS after CORRECT'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLN34F'
      CTITLE = 'HEAT FLUX FROM SOIL 3 TO SOIL 4 NOS after CORRECT'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLS12F'
      CTITLE = 'HEAT FLUX FROM SOIL 1 TO SOIL 2 SNW after CORRECT'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLS23F'
      CTITLE = 'HEAT FLUX FROM SOIL 2 TO SOIL 3 SNW after CORRECT'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HFLS34F'
      CTITLE = 'HEAT FLUX FROM SOIL 3 TO SOIL 4 SNW after CORRECT'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN
        CMARK  = 'A_GH'
        CTITLE = 'ALMA Qg '
        CUNIT  = 'W/M**2'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      ENDIF 
!
      RETURN
      END
