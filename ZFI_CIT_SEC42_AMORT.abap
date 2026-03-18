*&---------------------------------------------------------------------*
*& Report ZFI_CIT_SEC42_AMORT
*&---------------------------------------------------------------------*
*& Description: Section 42 Deductions - Amortization Computation
*& Transaction: ZFI_CIT_AMORT
*& Module:      FI - Tax Accounting
*& Project:     OVL - S/4 HANA Migration
*&---------------------------------------------------------------------*
REPORT zfi_cit_sec42_amort.

*----------------------------------------------------------------------*
* Type Definitions
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_block_master,
         mandt         TYPE mandt,
         block_name    TYPE char30,
         bukrs         TYPE bukrs,
         venture_code  TYPE char10,
         claim_type    TYPE char1,        " E = Exploration, P = Post Commercial
         prod_date     TYPE dats,         " Date of commencement of production
         surrendered   TYPE char1,        " Whether Surrendered (Y/N)
         surr_date     TYPE dats,         " Date of Surrender
         sched_date    TYPE dats,         " Date of Creation of schedule
       END OF ty_block_master,

       BEGIN OF ty_gl_post_comm,
         mandt      TYPE mandt,
         bukrs      TYPE bukrs,
         hkont      TYPE hkont,          " GL Account
         flow_type  TYPE char10,         " Flow Type / Transaction Type
       END OF ty_gl_post_comm,

       BEGIN OF ty_gl_instl,
         mandt      TYPE mandt,
         bukrs      TYPE bukrs,
         hkont      TYPE hkont,          " GL Account
         flow_type  TYPE char10,         " Flow Type / Transaction Type
       END OF ty_gl_instl,

       BEGIN OF ty_amort_sch,
         mandt      TYPE mandt,
         bukrs      TYPE bukrs,
         venture    TYPE char10,
         gjahr      TYPE gjahr,          " Fiscal Year
         hkont      TYPE hkont,          " GL Account
         surr_date  TYPE dats,           " Date of Surrender
         total_amt  TYPE wrbtr,          " Total Amount
         instl_amt  TYPE wrbtr,          " Installment Amount (Total/10)
         reversed   TYPE char1,          " Reversed (Y/N)
       END OF ty_amort_sch,

       BEGIN OF ty_amort_instl,
         mandt      TYPE mandt,
         bukrs      TYPE bukrs,
         venture    TYPE char10,
         gjahr      TYPE gjahr,          " Fiscal Year
         hkont      TYPE hkont,          " GL Account
         surr_date  TYPE dats,           " Date of Surrender
         instl_amt  TYPE wrbtr,          " Installment Amount
         instl_no   TYPE numc2,          " Installment Number (01-10)
         executed   TYPE char1,          " Executed (Y/N)
         reversed   TYPE char1,          " Reversed (Y/N)
         acct_upd   TYPE char1,          " Accounts Updated (Y/N)
       END OF ty_amort_instl,

       BEGIN OF ty_current_deduction,
         bukrs      TYPE bukrs,
         venture    TYPE char10,
         gjahr      TYPE gjahr,
         hkont      TYPE hkont,
         amount     TYPE wrbtr,
         description TYPE char50,
       END OF ty_current_deduction.

*----------------------------------------------------------------------*
* Internal Tables and Work Areas
*----------------------------------------------------------------------*
DATA: gt_block_master  TYPE TABLE OF ty_block_master,
      gs_block_master  TYPE ty_block_master,
      gt_gl_post_comm  TYPE TABLE OF ty_gl_post_comm,
      gs_gl_post_comm  TYPE ty_gl_post_comm,
      gt_gl_instl      TYPE TABLE OF ty_gl_instl,
      gs_gl_instl      TYPE ty_gl_instl,
      gt_amort_sch     TYPE TABLE OF ty_amort_sch,
      gs_amort_sch     TYPE ty_amort_sch,
      gt_amort_instl   TYPE TABLE OF ty_amort_instl,
      gs_amort_instl   TYPE ty_amort_instl,
      gt_current_ded   TYPE TABLE OF ty_current_deduction,
      gs_current_ded   TYPE ty_current_deduction.

DATA: gv_total_balance TYPE wrbtr,
      gv_instl_amount  TYPE wrbtr,
      gv_instl_year    TYPE gjahr,
      gv_counter       TYPE i.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:     p_jv    TYPE char10  OBLIGATORY.    " Joint Venture
  PARAMETERS:     p_bukrs TYPE bukrs   OBLIGATORY.    " Company Code
  PARAMETERS:     p_monat TYPE monat   OBLIGATORY.    " Period
  PARAMETERS:     p_gjahr TYPE gjahr   OBLIGATORY.    " Fiscal Year
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS:     p_rev   TYPE abap_bool AS CHECKBOX. " Reversal Flag
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.
  TEXT-001 = 'Selection Parameters'.
  TEXT-002 = 'Reversal Options'.

*----------------------------------------------------------------------*
* Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM validate_input.

  IF p_rev = abap_true.
    PERFORM process_reversal.
  ELSE.
    PERFORM process_amortization.
  ENDIF.

  PERFORM display_output.

*&---------------------------------------------------------------------*
*& Form VALIDATE_INPUT
*&---------------------------------------------------------------------*
*& Validates selection screen input parameters
*&---------------------------------------------------------------------*
FORM validate_input.

  " Validate Company Code
  SELECT SINGLE bukrs FROM t001
    WHERE bukrs = @p_bukrs
    INTO @DATA(lv_bukrs).
  IF sy-subrc <> 0.
    MESSAGE e001(zfi_sec42) WITH p_bukrs.
    " Company code &1 does not exist
  ENDIF.

  " Validate Joint Venture exists in Block Master
  SELECT SINGLE * FROM zfi_tax_sec42_block_master
    WHERE venture_code = @p_jv
      AND bukrs        = @p_bukrs
    INTO @gs_block_master.
  IF sy-subrc <> 0.
    MESSAGE e002(zfi_sec42) WITH p_jv p_bukrs.
    " Joint Venture &1 not found in Block Master for company code &2
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROCESS_AMORTIZATION
*&---------------------------------------------------------------------*
*& Main processing logic for amortization computation
*&---------------------------------------------------------------------*
FORM process_amortization.

  " Read Block Master entries for the given JV and Company Code
  SELECT * FROM zfi_tax_sec42_block_master
    WHERE venture_code = @p_jv
      AND bukrs        = @p_bukrs
    INTO TABLE @gt_block_master.

  IF gt_block_master IS INITIAL.
    MESSAGE s003(zfi_sec42) WITH p_jv.
    " No Block Master entries found for Joint Venture &1
    RETURN.
  ENDIF.

  LOOP AT gt_block_master INTO gs_block_master.

    CASE gs_block_master-claim_type.

      WHEN 'E'.  " Exploration
        PERFORM process_status_e.

      WHEN 'P'.  " Post Commercial Production
        PERFORM process_status_p.

      WHEN OTHERS.
        MESSAGE w004(zfi_sec42) WITH gs_block_master-venture_code
                                     gs_block_master-claim_type.
        " Unknown claim type &2 for venture &1
        CONTINUE.

    ENDCASE.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROCESS_STATUS_E
*&---------------------------------------------------------------------*
*& Process ventures with Status E (Exploration)
*& Check if surrendered: if NO, skip. If YES, process.
*&---------------------------------------------------------------------*
FORM process_status_e.

  " If not surrendered, close the loop (skip)
  IF gs_block_master-surrendered <> 'Y'.
    RETURN.
  ENDIF.

  " Venture is surrendered - read GL accounts from Table-2 (Post Commercial)
  SELECT * FROM zfi_tax_sec42_gl_post_comm
    WHERE bukrs = @p_bukrs
    INTO TABLE @gt_gl_post_comm.

  IF gt_gl_post_comm IS INITIAL.
    MESSAGE w005(zfi_sec42) WITH p_bukrs.
    " No GL accounts found in Post Commercial table for company code &1
    RETURN.
  ENDIF.

  " For each GL account, get balance using FAGLB03 logic
  LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.

    " Validate GL account exists in SKB1
    SELECT SINGLE saknr FROM skb1
      WHERE bukrs = @p_bukrs
        AND saknr = @gs_gl_post_comm-hkont
      INTO @DATA(lv_saknr).
    IF sy-subrc <> 0.
      MESSAGE w006(zfi_sec42) WITH gs_gl_post_comm-hkont p_bukrs.
      " GL account &1 not valid in company code &2
      CONTINUE.
    ENDIF.

    " Read GL balance from FAGLB03 (ACDOCA or FAGLFLEXT)
    PERFORM get_gl_balance
      USING    gs_block_master-venture_code
               gs_gl_post_comm-hkont
               p_bukrs
               p_gjahr
               p_monat
      CHANGING gv_total_balance.

    " Store current year deduction in temp table
    CLEAR gs_current_ded.
    gs_current_ded-bukrs      = p_bukrs.
    gs_current_ded-venture    = gs_block_master-venture_code.
    gs_current_ded-gjahr      = p_gjahr.
    gs_current_ded-hkont      = gs_gl_post_comm-hkont.
    gs_current_ded-amount     = gv_total_balance.
    gs_current_ded-description = 'Status E - Post Commercial GL Balance'.
    APPEND gs_current_ded TO gt_current_ded.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROCESS_STATUS_P
*&---------------------------------------------------------------------*
*& Process ventures with Status P (Post Commercial Production)
*& If surrendered YES -> Table-3 (Installments), compute amort schedule
*& If surrendered NO  -> Table-2 (Post Commercial), get GL balances
*&---------------------------------------------------------------------*
FORM process_status_p.

  IF gs_block_master-surrendered = 'Y'.
    " Surrendered: Use Table-3 GL Installments
    PERFORM process_surrendered_venture.
  ELSE.
    " Not surrendered: Use Table-2 GL Post Commercial
    PERFORM process_active_venture.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROCESS_SURRENDERED_VENTURE
*&---------------------------------------------------------------------*
*& For surrendered ventures: compute amortization schedule
*& Installment = Total Amount / 10, spread over 10 years
*&---------------------------------------------------------------------*
FORM process_surrendered_venture.

  DATA: lv_instl_year TYPE gjahr,
        lv_instl_no   TYPE numc2,
        lv_instl_amt  TYPE wrbtr.

  " Read GL accounts from Table-3 (Installments)
  SELECT * FROM zfi_tax_sec42_gl_instl
    WHERE bukrs = @p_bukrs
    INTO TABLE @gt_gl_instl.

  IF gt_gl_instl IS INITIAL.
    MESSAGE w007(zfi_sec42) WITH p_bukrs.
    " No GL accounts in installment table for company code &1
    RETURN.
  ENDIF.

  " Check if amortization schedule already exists
  SELECT * FROM zfi_tax_sec42_amort_sch
    WHERE venture = @p_jv
      AND bukrs   = @p_bukrs
    INTO TABLE @gt_amort_sch.

  " Check Date of Creation of schedule in Block Master
  IF gs_block_master-sched_date IS INITIAL.

    " Schedule does not exist - need to create it
    LOOP AT gt_gl_instl INTO gs_gl_instl.

      " Validate GL in SKB1
      SELECT SINGLE saknr FROM skb1
        WHERE bukrs = @p_bukrs
          AND saknr = @gs_gl_instl-hkont
        INTO @DATA(lv_saknr).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " Get total amount from JVTO1 (JV Transaction sub-totals)
      PERFORM get_jv_total
        USING    gs_block_master-venture_code
                 gs_gl_instl-hkont
                 gs_gl_instl-flow_type
                 p_bukrs
                 p_gjahr
                 p_monat
        CHANGING gv_total_balance.

      " Compute installment: Total / 10
      lv_instl_amt = gv_total_balance / 10.

      " Create Amortization Schedule entry
      CLEAR gs_amort_sch.
      gs_amort_sch-bukrs     = p_bukrs.
      gs_amort_sch-venture   = gs_block_master-venture_code.
      gs_amort_sch-gjahr     = p_gjahr.
      gs_amort_sch-hkont     = gs_gl_instl-hkont.
      gs_amort_sch-surr_date = gs_block_master-surr_date.
      gs_amort_sch-total_amt = gv_total_balance.
      gs_amort_sch-instl_amt = lv_instl_amt.
      gs_amort_sch-reversed  = 'N'.

      MODIFY zfi_tax_sec42_amort_sch FROM gs_amort_sch.

      " Create 10 yearly installment entries
      lv_instl_year = gs_block_master-surr_date+0(4).  " Year from surrender date

      DO 10 TIMES.
        lv_instl_no = sy-index.

        CLEAR gs_amort_instl.
        gs_amort_instl-bukrs     = p_bukrs.
        gs_amort_instl-venture   = gs_block_master-venture_code.
        gs_amort_instl-gjahr     = lv_instl_year.
        gs_amort_instl-hkont     = gs_gl_instl-hkont.
        gs_amort_instl-surr_date = gs_block_master-surr_date.
        gs_amort_instl-instl_amt = lv_instl_amt.
        gs_amort_instl-instl_no  = lv_instl_no.
        gs_amort_instl-executed  = 'N'.
        gs_amort_instl-reversed  = 'N'.
        gs_amort_instl-acct_upd  = 'N'.

        MODIFY zfi_tax_sec42_amort_sch_instl FROM gs_amort_instl.

        lv_instl_year = lv_instl_year + 1.
      ENDDO.

    ENDLOOP.

    " Update Block Master with schedule creation date
    gs_block_master-sched_date = sy-datum.
    MODIFY zfi_tax_sec42_block_master FROM gs_block_master.

  ENDIF.

  " Pick current year installment for deduction
  SELECT SINGLE * FROM zfi_tax_sec42_amort_sch_instl
    WHERE venture  = @p_jv
      AND bukrs    = @p_bukrs
      AND gjahr    = @p_gjahr
      AND executed = 'N'
      AND reversed = 'N'
    INTO @gs_amort_instl.

  IF sy-subrc = 0.
    " Store deduction
    CLEAR gs_current_ded.
    gs_current_ded-bukrs      = p_bukrs.
    gs_current_ded-venture    = gs_block_master-venture_code.
    gs_current_ded-gjahr      = p_gjahr.
    gs_current_ded-hkont      = gs_amort_instl-hkont.
    gs_current_ded-amount     = gs_amort_instl-instl_amt.
    gs_current_ded-description = 'Status P - Surrendered Installment'.
    APPEND gs_current_ded TO gt_current_ded.

    " Mark installment as executed
    gs_amort_instl-executed = 'Y'.
    MODIFY zfi_tax_sec42_amort_sch_instl FROM gs_amort_instl.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROCESS_ACTIVE_VENTURE
*&---------------------------------------------------------------------*
*& For active (not surrendered) Status P ventures
*& Read from Table-2 and get GL balances
*&---------------------------------------------------------------------*
FORM process_active_venture.

  " Read GL accounts from Table-2 (Post Commercial Production)
  SELECT * FROM zfi_tax_sec42_gl_post_comm
    WHERE bukrs = @p_bukrs
    INTO TABLE @gt_gl_post_comm.

  IF gt_gl_post_comm IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.

    " Validate GL in SKB1
    SELECT SINGLE saknr FROM skb1
      WHERE bukrs = @p_bukrs
        AND saknr = @gs_gl_post_comm-hkont
      INTO @DATA(lv_saknr).
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    " Get GL balance via JVTO1
    PERFORM get_jv_total
      USING    gs_block_master-venture_code
               gs_gl_post_comm-hkont
               gs_gl_post_comm-flow_type
               p_bukrs
               p_gjahr
               p_monat
      CHANGING gv_total_balance.

    " Store current year deduction
    CLEAR gs_current_ded.
    gs_current_ded-bukrs      = p_bukrs.
    gs_current_ded-venture    = gs_block_master-venture_code.
    gs_current_ded-gjahr      = p_gjahr.
    gs_current_ded-hkont      = gs_gl_post_comm-hkont.
    gs_current_ded-amount     = gv_total_balance.
    gs_current_ded-description = 'Status P - Active GL Balance'.
    APPEND gs_current_ded TO gt_current_ded.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form PROCESS_REVERSAL
*&---------------------------------------------------------------------*
*& Reversal of ZFI_CIT_AMORT entries
*& Marks installment rows as reversed and resets executed flags
*&---------------------------------------------------------------------*
FORM process_reversal.

  DATA: lt_amort_instl TYPE TABLE OF ty_amort_instl.

  " Read all installment entries for the venture/year
  SELECT * FROM zfi_tax_sec42_amort_sch_instl
    WHERE venture = @p_jv
      AND bukrs   = @p_bukrs
    INTO TABLE @lt_amort_instl.

  IF lt_amort_instl IS INITIAL.
    MESSAGE s008(zfi_sec42) WITH p_jv.
    " No amortization entries found for venture &1
    RETURN.
  ENDIF.

  " Mark all rows as reversed, reset executed flag
  LOOP AT lt_amort_instl INTO gs_amort_instl.
    gs_amort_instl-reversed = 'Y'.
    gs_amort_instl-executed = 'N'.
    MODIFY zfi_tax_sec42_amort_sch_instl FROM gs_amort_instl.
  ENDLOOP.

  " Update Amortization Schedule - mark as reversed
  SELECT * FROM zfi_tax_sec42_amort_sch
    WHERE venture = @p_jv
      AND bukrs   = @p_bukrs
    INTO TABLE @gt_amort_sch.

  LOOP AT gt_amort_sch INTO gs_amort_sch.
    gs_amort_sch-reversed = 'Y'.
    MODIFY zfi_tax_sec42_amort_sch FROM gs_amort_sch.
  ENDLOOP.

  MESSAGE s009(zfi_sec42) WITH p_jv p_gjahr.
  " Reversal completed for venture &1 fiscal year &2

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_GL_BALANCE
*&---------------------------------------------------------------------*
*& Read GL account balance (FAGLB03 equivalent)
*& Uses ACDOCA / FAGLFLEXT for balance retrieval
*&---------------------------------------------------------------------*
FORM get_gl_balance
  USING    iv_venture  TYPE char10
           iv_hkont    TYPE hkont
           iv_bukrs    TYPE bukrs
           iv_gjahr    TYPE gjahr
           iv_monat    TYPE monat
  CHANGING cv_balance  TYPE wrbtr.

  DATA: lv_period_field TYPE string.

  cv_balance = 0.

  " Build period column name for FAGLFLEXT
  CONCATENATE 'HSL' iv_monat INTO lv_period_field.
  CONDENSE lv_period_field NO-GAPS.

  " Read from FAGLFLEXT (New GL totals table)
  SELECT SUM( hsl01 ) + SUM( hsl02 ) + SUM( hsl03 ) +
         SUM( hsl04 ) + SUM( hsl05 ) + SUM( hsl06 ) +
         SUM( hsl07 ) + SUM( hsl08 ) + SUM( hsl09 ) +
         SUM( hsl10 ) + SUM( hsl11 ) + SUM( hsl12 )
    FROM faglflext
    WHERE rbukrs = @iv_bukrs
      AND racct  = @iv_hkont
      AND gjahr  = @iv_gjahr
    INTO @cv_balance.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_JV_TOTAL
*&---------------------------------------------------------------------*
*& Get JV transaction sub-totals from JVTO1
*&---------------------------------------------------------------------*
FORM get_jv_total
  USING    iv_venture   TYPE char10
           iv_hkont     TYPE hkont
           iv_flow_type TYPE char10
           iv_bukrs     TYPE bukrs
           iv_gjahr     TYPE gjahr
           iv_monat     TYPE monat
  CHANGING cv_total     TYPE wrbtr.

  cv_total = 0.

  " Read JV transaction totals from JVTO1
  SELECT SUM( wrbtr )
    FROM jvto1
    WHERE bukrs     = @iv_bukrs
      AND venture   = @iv_venture
      AND hkont     = @iv_hkont
      AND gjahr     = @iv_gjahr
      AND monat    <= @iv_monat
    INTO @cv_total.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*& Display Section 42 deduction results using ALV
*&---------------------------------------------------------------------*
FORM display_output.

  DATA: lo_alv       TYPE REF TO cl_salv_table,
        lo_columns   TYPE REF TO cl_salv_columns_table,
        lo_column    TYPE REF TO cl_salv_column,
        lo_functions TYPE REF TO cl_salv_functions_list,
        lo_display   TYPE REF TO cl_salv_display_settings,
        lx_msg       TYPE REF TO cx_salv_msg.

  IF gt_current_ded IS INITIAL.
    MESSAGE s010(zfi_sec42).
    " No Section 42 deductions found for the given selection
    RETURN.
  ENDIF.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = lo_alv
        CHANGING  t_table      = gt_current_ded ).

      " Enable ALV functions (sort, filter, export)
      lo_functions = lo_alv->get_functions( ).
      lo_functions->set_all( abap_true ).

      " Set column texts
      lo_columns = lo_alv->get_columns( ).
      lo_columns->set_optimize( abap_true ).

      lo_column = lo_columns->get_column( 'BUKRS' ).
      lo_column->set_short_text( 'CoCd' ).
      lo_column->set_medium_text( 'Company Code' ).

      lo_column = lo_columns->get_column( 'VENTURE' ).
      lo_column->set_short_text( 'JV' ).
      lo_column->set_medium_text( 'Joint Venture' ).

      lo_column = lo_columns->get_column( 'GJAHR' ).
      lo_column->set_short_text( 'FY' ).
      lo_column->set_medium_text( 'Fiscal Year' ).

      lo_column = lo_columns->get_column( 'HKONT' ).
      lo_column->set_short_text( 'GL Acct' ).
      lo_column->set_medium_text( 'GL Account' ).

      lo_column = lo_columns->get_column( 'AMOUNT' ).
      lo_column->set_short_text( 'Amount' ).
      lo_column->set_medium_text( 'Deduction Amount' ).

      lo_column = lo_columns->get_column( 'DESCRIPTION' ).
      lo_column->set_short_text( 'Desc' ).
      lo_column->set_medium_text( 'Description' ).

      " Set display title
      lo_display = lo_alv->get_display_settings( ).
      lo_display->set_list_header( 'Section 42 Deductions - Current Year' ).
      lo_display->set_striped_pattern( abap_true ).

      lo_alv->display( ).

    CATCH cx_salv_msg INTO lx_msg.
      MESSAGE lx_msg TYPE 'E'.
  ENDTRY.

ENDFORM.
