 DATA: lo_model TYPE REF TO /scwm/if_pack.

 DATA(lo_packing) = NEW /scwm/cl_wm_packing(  ).

  lo_packing->init(
    EXPORTING
      iv_lgnum = "Put your lgnum
      iv_procty = "Put your proctype
      is_pack_controle = VALUE #( processor_det = abap_true )
   ).

  lo_packing->init_pack(
    EXPORTING
      iv_badi_appl = 'WME'
      it_guid_hu   = VALUE #( ( guid_hu = "Add your single HU or fill table ) )
      iv_no_refresh = abap_true
      iv_lgnum = "Put your lgnum
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
      iv_guid_hu   = "Use single HU
      iv_model     = lo_model
    EXCEPTIONS
      error        = 1
      not_complete = 2
      OTHERS       = 3.
  IF sy-subrc <> 0.
  ENDIF.

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

  /scwm/cl_tm=>cleanup( ).