! 陸面過程計算のための諸準備
! 99/07/xx 保坂征宏
! 99/08/04 保坂征宏 大泉さんに渡すバージョンフィックス
!
      SUBROUTINE PRESIB_MAIN  ( 
     I    NMAX_01     , NMAX_1      , NMAX_2      , NMAX_3      ,
     I    NMAX_4      , NMAX        ,
#ifdef MONYOS
     I    DELT_SOIL   ,
#endif
     I    NTYP        , 
     I    CVR_SNW_INV , 
     I    DEP_SNOW    , RHO_SNOW_INV   ,
     I    WTR_SNOW    , GLA_SNOW    , 
     I    TMP_SOIL    , FR_WTR_SOIL , FR_GLA_SOIL , 
     I    TMP_SNSL    , FR_WTR_SNSL , FR_GLA_SNSL ,
     O    HDF_GRSK    , HDF_SNSK    ,
     O    HDF_SOIL_H  , HDF_SNSL_H  ,
     O    HDF_SNOW_H  , 
     O    CAP_SOIL_TOP, CAP_SNOW_TOP, 
     O    ENG_SOIL_TOP   )
!
      USE SIBPRM , ONLY :
     1    IDX , 
     1    ISN , 
     1    IDP , 
     1    ICG 
!
      IMPLICIT NONE
!
      INTEGER,INTENT(IN)    :: NMAX_01 (3)
      INTEGER,INTENT(IN)    :: NMAX_1  (3)
      INTEGER,INTENT(IN)    :: NMAX_2  (3)
      INTEGER,INTENT(IN)    :: NMAX_3  (3)
      INTEGER,INTENT(IN)    :: NMAX_4  (3)
      INTEGER,INTENT(IN)    :: NMAX
!
      INTEGER,INTENT(IN)    :: NTYP(IDX)
!
      REAL(8),INTENT(IN)    :: DEP_SNOW  (IDX,ISN+1)    ! 積雪層の厚さ(m)
      REAL(8),INTENT(IN)    :: RHO_SNOW_INV (IDX,ISN)    ! 積雪層の密度(kg/m3)
      REAL(8),INTENT(IN)    :: WTR_SNOW  (IDX)          ! 
      REAL(8),INTENT(IN)    :: GLA_SNOW  (IDX)          ! 
      REAL(8),INTENT(IN)    :: CVR_SNW_INV  (IDX)          ! 
!
#ifdef MONYOS
      REAL(8),INTENT(IN)    :: DELT_SOIL 
#endif
!
      REAL(8),INTENT(IN)    :: TMP_SOIL   (IDX,IDP)  
      REAL(8),INTENT(IN)    :: TMP_SNSL   (IDX,IDP)  
!
      REAL(8),INTENT(IN)    :: FR_WTR_SOIL(IDX,IDP)     ! 空隙中の水の割合
!                                                        (体積比)
      REAL(8),INTENT(IN)    :: FR_GLA_SOIL(IDX,IDP)     ! 空隙中の氷の割合
!                                                        (体積比)
      REAL(8),INTENT(IN)    :: FR_WTR_SNSL(IDX,IDP)     ! 空隙中の水の割合
!                                                        (積雪下土壌１層)
      REAL(8),INTENT(IN)    :: FR_GLA_SNSL(IDX,IDP)     ! 空隙中の氷の割合
!                                                        (積雪下土壌１層)!
! OUTPUT
!
! 熱伝導係数
!
      REAL(8),INTENT(OUT)   :: HDF_GRSK   (IDX,2)       ! 土   SK-L1,L1-L2
      REAL(8),INTENT(OUT)   :: HDF_SNSK   (IDX,2)       ! 雪下 SK-S1,S1-X 
      REAL(8),INTENT(OUT)   :: HDF_SNOW_H (IDX,ISN+1)   
!                                     ! 雪   S1-S2,S2-S3,S3-S4,SX-L1,L1-L2
      REAL(8),INTENT(OUT)   :: HDF_SOIL_H (IDX,IDP)     ! 土 1-2,2-3,3-
      REAL(8),INTENT(OUT)   :: HDF_SNSL_H (IDX,IDP)     ! 雪下土   1-2
!
! 比熱
!
      REAL(8),INTENT(OUT)   :: CAP_SOIL_TOP (IDX) 
      REAL(8),INTENT(OUT)   :: CAP_SNOW_TOP (IDX) 
!
! 土壌第一層エネルギー ( 雪無しなら雪無し、雪有りなら雪有り域だけでの平均 )
!
      REAL(8),INTENT(OUT)   :: ENG_SOIL_TOP (IDX) 
!
      LOGICAL, SAVE :: LFIRST 
      DATA LFIRST  / .TRUE. / 
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'PRESIB_MAIN 99/07 POCHAKA'
        LFIRST = .FALSE.
      ENDIF 
!
! --------------------                                                   
! > 熱伝導係数の計算 <
! --------------------                                                   
!
        CALL PRESIB_CONDUC_ALL (
     I    NMAX_01     , NMAX_1      , NMAX_2      , NMAX_3      ,
     I    NMAX_4      , NMAX        , 
#ifdef MONYOS
     I    DELT_SOIL   ,
#endif
     I    NTYP        , 
     I    DEP_SNOW    , RHO_SNOW_INV,
     I    FR_WTR_SOIL , FR_GLA_SOIL , FR_WTR_SNSL , FR_GLA_SNSL ,
     O    HDF_GRSK    , HDF_SNSK    ,
     O    HDF_SOIL_H  , HDF_SNSL_H  ,
     O    HDF_SNOW_H  )
!
! -------------------------
! > 土壌/積雪第一層の比熱 <
! -------------------------
!
      CALL PRESIB_CAP_SSTOP (
     I   1               , NMAX_01(3)    ,
     I   NMAX_01(2)      , NMAX          , 
     I   NTYP            , 
     I   CVR_SNW_INV     , 
     I   TMP_SOIL        , FR_WTR_SOIL     , FR_GLA_SOIL   , 
     I   TMP_SNSL        , FR_WTR_SNSL     , FR_GLA_SNSL   , 
     I   WTR_SNOW        , GLA_SNOW      , 
     O   CAP_SOIL_TOP    , CAP_SNOW_TOP  , 
     O   ENG_SOIL_TOP )  
!
      RETURN
      END
