      MODULE COM_RUNCONF          ! �I�t���C���p
      

!! ���s�W���u�ݒ��� ( �W���u���ň�� )

!! ���̐ݒ�l��default�̒l�B
!! com_runconf_ini�ŁA�������̒l���u�������B

! run configuration information module file
!
!--- FLG0 
!
!     INTEGER,SAVE :: 
!    1   JCN_KT0_START = 0   ! KT=0 ����̃X�^�[�g�Ȃ� 1 
!     NAMELIST / NAMFLG0 / JCN_KT0_START 
!
!--- FLG1 ����Ȃ��t���O ( �����֌W )

      INTEGER,SAVE :: 
     1   JCNLSM   = 1    ,    ! 1 L3SiB ( ���� ) , 2 SiB0007 
     1   JCNTTICE = 1  
!
      INTEGER,SAVE ::          ! ���j�^
     1   JCNMMM   = 0,         ! �ēc���j�^               980730 �ۍ�
     1   JCNGRP   = 1          ! EP-FLUX and 
!                              ! GRIPS MONITOR, i.e,   zonal mean daily values
!                                     T(90N),U(60N), T(90S),U(60S)
!
      INTEGER, SAVE :: 
     1  JCNIMNT    = 999, ! �������j�^�o�͊Ԋu�B 980804 �ۍ� �� INTMNT
     1  JCNIMNTDAY =  24, ! �������j�^�o�͊Ԋu�B
     1  JCNIMNT6HR =   6

      NAMELIST / SIB0109_COM_RUNCONF /       
     1   JCNIMNT, JCNIMNTDAY, JCNIMNT6HR
!
      CONTAINS
!
! ===============================================================
!
      SUBROUTINE COM_RUNCONF_INI
!
        use com_stdinout_unit , only : iunit_in , iunit_out  
!
       !--- �l�[�����X�g�ǂݍ��݂ɂ��ύX 
!
        REWIND(iunit_in)
        READ  (iunit_in ,SIB0109_COM_RUNCONF)
        WRITE (iunit_out,SIB0109_COM_RUNCONF)

      END SUBROUTINE COM_RUNCONF_INI
!====================================================================
      END MODULE COM_RUNCONF

