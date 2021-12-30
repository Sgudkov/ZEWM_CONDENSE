*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(IV_GUID_HU) TYPE  /SCWM/GUID_HU
*"     VALUE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"----------------------------------------------------------------------

 DATA: lo_model TYPE REF TO /scwm/if_pack.

 DATA(lo_packing) = NEW /scwm/cl_wm_packing(  ).

  lo_packing->init(
    EXPORTING
      iv_lgnum = iv_lgnum
      iv_procty = "Put your proctype
      is_pack_controle = VALUE #( processor_det = abap_true )
   ).

  lo_packing->init_pack(
    EXPORTING
      iv_badi_appl = 'WME'
      it_guid_hu   = VALUE #( ( guid_hu = iv_guid_hu ) )
      iv_no_refresh = abap_true
      iv_lgnum = iv_lgnum
    IMPORTING
      et_huhdr = DATA(lt_hudr) ).

  lo_model ?= lo_packing.
  lo_model->go_log->init( ).

  " Transaction Manager
  /scwm/cl_tm=>cleanup(
    EXPORTING
      iv_lgnum = "Put lgnum ).

  CALL FUNCTION '/SCWM/TO_LOG_GET_LOGNR'
    EXPORTING
      iv_memory = 'X'.

  "Able to use loop of lt_hudr
  CALL FUNCTION '/SCWM/WC_CONDENSE_HIERARCHY'
    EXPORTING
      iv_guid_hu   = iv_guid_hu
      iv_model     = lo_model
    EXCEPTIONS
      error        = 1
      not_complete = 2
      OTHERS       = 3.
  "sy-subrc able to <> 0, don't check it.
  "Check gv_chenged below
  
  "Like this you able to get message tab
  data(lt_bapiret) = lo_model->go_log->get_prot( ).
  
  "This parameter contains or doesn't an error 
  data(lv_severity) = lo_model->go_log->get_severity( ).

  IF /scwm/cl_pack=>gv_changed IS NOT INITIAL.
    lo_model->save(
      EXPORTING
        iv_commit = space
        iv_wait   = space
     ).
    IF sy-subrc <> 0.
      ROLLBACK WORK.
	ELSE.
	  COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.
  
  "Be aware to use lo_model after line below, method cleanup will clean all  
  /scwm/cl_tm=>cleanup( ).