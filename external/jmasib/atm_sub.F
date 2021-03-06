! ! 大気強制力 関連ツール
!   ATM_INTERP     内挿。R4 -> R8 に。 
!   ATM_GETID_XX   
!   atm_data_maxmin     R4 データの最大値最小値出力
!=====================================================
      SUBROUTINE ATM_INTERP ( 
     I    DATA_PRE , DATA_NEXT , WGT_NEXT , 
     O    DATA_OUT )
!
      USE PRM , ONLY :    IDIM , JDIM
!
      IMPLICIT NONE 
!
      REAL(4),INTENT(IN)   :: DATA_PRE (IDIM*JDIM)
      REAL(4),INTENT(IN)   :: DATA_NEXT(IDIM*JDIM)
      REAL(8),INTENT(IN)   :: WGT_NEXT
!
      REAL(8),INTENT(OUT)  :: DATA_OUT (IDIM*JDIM)
!
      INTEGER :: IJ 
!
      DO IJ=1,IDIM*JDIM
        DATA_OUT(IJ) =   (1-WGT_NEXT) * DATA_PRE  (IJ) 
     1                 +   WGT_NEXT   * DATA_NEXT (IJ)
      ENDDO
!
      RETURN
      END
!====================================================
      SUBROUTINE ATM_GETID_XX ( ID_NOW , IX , ID_PRE , ID_NEXT ) 
!
!  ID_NOW から前後 6 時間以内の、IX + 6n (n=0,1,2,3) 時を探す。
!  IX は 0-5 
!  例
!     ID_NOW=1987,1,2,4 、IX = 3 -> ID_PRE=1987,1,2,3 ID_NEXT=1987,1,2,9
!     一致したときは、ID_PRE=ID_NOW, ID_NEXT が 6 時間後
!
      use calendar , only :
     1     calendar_run_getid
!
      IMPLICIT NONE
!
      INTEGER,INTENT(IN)   :: ID_NOW (5)
      INTEGER,INTENT(IN)   :: IX 
      INTEGER,INTENT(OUT)  :: ID_PRE (5)
      INTEGER,INTENT(OUT)  :: ID_NEXT(5)
!
      INTEGER :: ID_NOW_WORK (5)
      INTEGER :: K
      INTEGER :: KT_LAG
!
      IF ( IX.LT.0 .OR. IX.GE.6 ) THEN 
        WRITE(6,*)  'ATM_GETID_XX ERROR IX ' , IX
        STOP 999
      ENDIF
!
      KT_LAG = 0 
      CALL CALENDAR_RUN_GETID ( ID_NOW , ID_NOW_WORK , KT_LAG )
!
!  PRE を探す
!
      KT_LAG = 0 
      CALL CALENDAR_RUN_GETID ( ID_NOW_WORK , ID_PRE , KT_LAG ) 
!
      KT_LAG = -1 
      DO K = 0,5
        IF ( MOD(ID_PRE(4),6) .EQ. IX ) GOTO 1000 
        CALL CALENDAR_RUN_GETID ( ID_PRE , ID_PRE , KT_LAG ) 
      ENDDO
 1000 CONTINUE 
!
!      IF ( ID_PRE(1).EQ.1986 ) THEN
!        ID_PRE(1) = 1987 
!      ENDIF
!
!  NEXT を探す
!
      KT_LAG = 1 
      CALL CALENDAR_RUN_GETID ( ID_NOW_WORK , ID_NEXT , KT_LAG ) 
!
      DO K = 1,5
        IF ( MOD(ID_NEXT(4),6) .EQ. IX ) GOTO 1100 
        CALL CALENDAR_RUN_GETID ( ID_NEXT , ID_NEXT , KT_LAG ) 
      ENDDO
 1100 CONTINUE 
!
!
!      IF ( ID_NEXT(1).EQ.1989 ) THEN
!        ID_NEXT(1) = 1988
!      ENDIF
!
      RETURN
      END SUBROUTINE ATM_GETID_XX
!===============================================================
      subroutine atm_data_maxmin ( r4 , idim , jdim , imask , c4 ) 
!
      implicit none
      integer,intent(in)      :: idim
      integer,intent(in)      :: jdim
      integer,intent(in)      :: imask(idim,jdim)
      real(4),intent(in)      :: r4(idim,jdim)
      character(4),intent(in) :: c4
!
      real(4)  :: dat_min
      real(4)  :: dat_max 
      integer  :: i
      integer  :: j
!
      dat_min =   1.E35
      dat_max = - 1.E35
!
      do j=1,jdim
      do i=1,idim
         if(dat_min.gt. r4(i,j).AND.imask(i,j).gt.0) then
             dat_min=r4(i,j)
         endif
         if(dat_max.lt.r4(i,j).AND.imask(i,j).gt.0 ) then
             dat_max=r4(i,j)
         endif
      enddo
      enddo
!
#if defined(CHECK) || defined(DEBUG)
      write(*,*) 'MAXIMUM ' , C4 , ' = ' , dat_max
      write(*,*) 'MINIMUM ' , C4 , ' = ' , dat_min
#endif
!
      return
      end  

