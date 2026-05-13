* Paste this block into SMARTFORMS -> Global Definitions -> Initialization tab (Code area)
* Set Output Parameters tab to include the tables/work areas used downstream.
* Source: Adobe Form ZSANY_INVOICE_INTERFACE

"**************ALL DATA DECLARATION***********
*DATA : LV_PO_NO type vbak-bstnk,
*       lv_po_date type vbak-bstdk,
*       lv_order type vbrp-aubel,
*       lv_order_date type vbak-bstdk.
*
*BREAK abap2.
*BREAK prashantk.
*BREAK priyankaa.
DATA wa_final TYPE st_final.
DATA : temp TYPE string,
       seri TYPE string.
DATA BEGIN OF textheader.
INCLUDE STRUCTURE thead.
DATA END OF textheader.
DATA BEGIN OF textlines OCCURS 10.
INCLUDE STRUCTURE tline.
DATA END OF textlines.
CLEAR textheader.
DATA : wa_vbrk TYPE vbrk.
*DATA : I_FKART TYPE FKART.
*DATA : NAME TYPE STRING.
DATA : text TYPE  string.
DATA : gi_longtext      TYPE STANDARD TABLE OF tline WITH HEADER LINE,
       gi_longtext_ser  TYPE STANDARD TABLE OF tline WITH HEADER LINE,
       gv_object        TYPE thead-tdobject , "VALUE 'Object name',
       gv_id            TYPE thead-tdid , " VALUE 'ID Name',
       gv_longtext_name TYPE thead-tdname, "  VALUE 'LongText Name',
       gv_langu         TYPE thead-tdspras,
       gv_count         TYPE i.
DATA: l_name TYPE tdobname."TR
DATA : id       TYPE thead-tdid,
       language TYPE thead-tdspras,
       name     TYPE thead-tdname,
       object   TYPE thead-tdobject,
       it_lines TYPE TABLE OF tline,
       wa_lines TYPE tline.
DATA : wa_vbrk2 TYPE vbrk.
DATA : wa_vbrk1 TYPE vbrk.
DATA : amt TYPE pc207-betrg.
*++ by ps dt 29.05.2025 FUN :- Bharat
TYPES : BEGIN OF TY_VBFA,
        vbeln    type VBELN_NACH ,
        vbtyp_v  type VBTYP_N,
        vbelv    type VBELN_VON,
        END OF ty_vbfa.
DATA : WA_VBFA TYPE TY_VBFA.
*-- by ps dt 29.05.2025  FUN :- Bharat
***********INITIALIZATION*****************
*DATA : wa_kna1 TYPE kna1,
*       wa_kna2 TYPE kna1.
DATA : r_name TYPE thead-tdname.
"ADD START BY RUKESH IN TP ON 21.09.2022
*
*DATA: LV_NETWR TYPE VBRK-NETWR,"P DECIMALS 2,
*      LV_VBELN TYPE VBELN_VF.
*
*SELECT SINGLE VBELN NETWR  FROM VBRK
*      INTO (LV_VBELN, LV_NETWR)
*      WHERE VBELN = I_VBELN.
"ADD END BY RUKESH IN TP ON 21.09.2022
*       it_lines TYPE TABLE OF TLINE,
*       wa_lines TYPE TLINE.
SELECT *
  FROM vbrk
  INTO TABLE it_vbrk
  WHERE vbeln = i_vbeln.
*-------------------------------------------------------------------------*YJ FOR QR CODE
DATA: gt_zeydigi_einv_azr TYPE TABLE OF zeydigi_einv_azr.
DATA: gv_first TYPE string.
DATA: gv_second TYPE string.
DATA: gv_third TYPE string.
DATA: gv_fourth TYPE string.
DATA: lv_dynamic_len TYPE string.
DATA: lv_len TYPE string.
DATA: gv_signedqr TYPE string.
DATA: s_vbln TYPE string.
*------------------------------------------------------------------------------------
**READ TABLE IT_VBRK INTO WA_VBRK WITH KEY VBELN = I_VBELN.
**
**SELECT SINGLE *
**  FROM ZEYDIGI_EINV_AZR
**  INTO GS_ZEYDIGI_EINV_AZR
**  WHERE DOCUMENTNUMBER EQ I_VBELN
**    AND BUKRS eq WA_VBRK-BUKRS.
**
**  IF GS_ZEYDIGI_EINV_AZR-SIGNED_QR IS NOT INITIAL.
**      GV_QRCODE2 = GS_ZEYDIGI_EINV_AZR-SIGNED_QR.
**      LV_DYNAMIC_LEN = STRLEN( GV_QRCODE2 ).
**     IF LV_DYNAMIC_LEN GT 765.
**        LV_LEN    = LV_DYNAMIC_LEN - 765.
**        gv_first  = GV_QRCODE2(255).
**        gv_second = GV_QRCODE2+255(255).
**        gv_third  = GV_QRCODE2+510(255).
**        gv_fourth = GV_QRCODE2+765(lv_len).
**     ENDIF.
**
**     CLEAR gv_SIGNEDQR.
**     CONCATENATE gv_first gv_second gv_third gv_fourth INTO gv_SIGNEDQR.
**       TRY .
**       cl_rstx_barcode_renderer=>qr_code(
**       EXPORTING
**           i_module_size      = 30
**           i_mode             = 'A'
**           i_error_correction = 'H'
**           i_barcode_text     = gv_SIGNEDQR
**       IMPORTING
**           e_bitmap           = gv_qcode
**               ).
**
**  CATCH cx_rstx_barcode_renderer.
**
**  ENDTRY.
**
**    ENDIF.
*------------------------------------------------------------------------------------
*BREAK ABAP3.
*IF I_VBELN IS NOT INITIAL.
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*  EXPORTING
*    input         = I_VBELN
*  IMPORTING
*    OUTPUT        = S_VBLN .
*
*  SELECT *
*  FROM ZEYDIGI_EINV_AZR
*  INTO CORRESPONDING FIELDS OF TABLE GT_ZEYDIGI_EINV_AZR
*  FOR ALL ENTRIES IN IT_VBRK
*  WHERE DOCUMENTNUMBER eq S_VBLN
*    and BUKRS eq IT_VBRK-BUKRS.
*
*    SELECT SINGLE * FROM VBRK INTO WA_VBRK
*      WHERE VBELN = I_VBELN.
*
*SELECT SINGLE * FROM VBRP INTO WA_VBRP
*      WHERE VBELN = I_VBELN.
*
*      SELECT SINGLE *
*    FROM KNA1
*    INTO WA_KNA1
*    WHERE KUNNR = WA_VBRK-KUNRG.
*
*   SELECT SINGLE GSTIN FROM J_1BBRANCH
*     INTO WA_QR-GSTIN
*     WHERE BUKRS = WA_VBRK-BUKRS
*     AND BRANCH = WA_VBRP-WERKS.
*
*ENDIF.
*
**  SELECT *
**  FROM ZEYDIGI_EINV_AZR
**  INTO CORRESPONDING FIELDS OF TABLE GT_ZEYDIGI_EINV_AZR
**  FOR ALL ENTRIES IN IT_VBRK
**  WHERE DOCUMENTNUMBER eq I_VBELN
**    and BUKRS eq IT_VBRK-BUKRS.
***    and FISCALYEAR eq IT_VBRK-GJAHR.
*
*break abap4.
*WA_QR-DOCUMENTNUMBER = I_VBELN.
*WA_QR-DOCUMENTDATE = WA_VBRK-FKDAT.
*WA_QR-PROFITCENTRE1 = WA_VBRP-PRCTR.
**WA_QR-GSTIN =
*IF  ( WA_KNA1-STCD3 = '' OR WA_KNA1-STCD3 = 'NA' ) AND ( WA_VBRK-FKART = 'ZM76' OR WA_VBRK-FKART = 'ZM72' ).
*
*  CALL FUNCTION 'ZAGST_GENERATE_B2C_QR_CODE'
*    EXPORTING
*      IM_V_COMPCODE       = WA_VBRK-BUKRS
*      IM_V_PLANT          = WA_VBRP-WERKS
*      IM_B2C_QR_INV       = WA_QR
*   IMPORTING
*     EX_V_QRCODE         = gv_SIGNEDQR
**   EXCEPTIONS
**     NO_QR_CODE          = 1
**     OTHERS              = 2
*            .
*  IF SY-SUBRC <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*   TRY .
*    cl_rstx_barcode_renderer=>qr_code(
*  EXPORTING
*    i_module_size      = 30
*    i_mode             = 'A'
*    i_error_correction = 'H'
*    i_barcode_text     = gv_SIGNEDQR "GS_ZEYDIGI_EINV_AZR-SIGNED_QR
*  IMPORTING
*    e_bitmap           = gv_qcode
*       ).
*
*  CATCH cx_rstx_barcode_renderer.
*
*  ENDTRY.
*
*  ELSE.
*
*
*LOOP AT GT_ZEYDIGI_EINV_AZR INTO GS_ZEYDIGI_EINV_AZR.
*  IF GS_ZEYDIGI_EINV_AZR-SIGNED_QR IS NOT INITIAL.
*  GV_QRCODE2 = GS_ZEYDIGI_EINV_AZR-SIGNED_QR.
*  LV_DYNAMIC_LEN = STRLEN( GV_QRCODE2 ).
*     IF LV_DYNAMIC_LEN GT 765.
*     LV_LEN    = LV_DYNAMIC_LEN - 765.
*     gv_first  = GV_QRCODE2(255).
*     gv_second = GV_QRCODE2+255(255).
*     gv_third  = GV_QRCODE2+510(255).
*     gv_fourth = GV_QRCODE2+765(lv_len).
*     ENDIF.
*
*CLEAR gv_SIGNEDQR.
*CONCATENATE gv_first gv_second gv_third gv_fourth INTO gv_SIGNEDQR.
*
*  TRY .
*    cl_rstx_barcode_renderer=>qr_code(
*  EXPORTING
*    i_module_size      = 30
*    i_mode             = 'A'
*    i_error_correction = 'H'
*    i_barcode_text     = gv_SIGNEDQR "GS_ZEYDIGI_EINV_AZR-SIGNED_QR
*  IMPORTING
*    e_bitmap           = gv_qcode
*       ).
*
*  CATCH cx_rstx_barcode_renderer.
*
*  ENDTRY.
*
*ENDIF.
*
*ENDLOOP.
*ENDIF.
*-------------------------------------------------------------------------*
*-------------------------------------------------------------------------*
*
*BREAK kpitabap.
IF it_vbrk IS NOT INITIAL.
  SELECT *
    FROM vbrp
    INTO TABLE it_vbrp
    FOR ALL ENTRIES IN it_vbrk
    WHERE vbeln = it_vbrk-vbeln.
  SELECT *
    FROM konv
    INTO TABLE it_konv
    FOR ALL ENTRIES IN it_vbrk
    WHERE knumv = it_vbrk-knumv.
  SELECT *
    FROM zsany_test
    INTO TABLE @DATA(lt_table)
    FOR ALL ENTRIES IN @it_vbrk
    WHERE kunag = @it_vbrk-kunag
    AND fkart = @it_vbrk-fkart.   " ADDED BY APARNA PHALKE ON 14.02.2023
ENDIF.
*BREAK ABAP4.
IF it_vbrp IS NOT INITIAL.
  SELECT *
    FROM likp
    INTO TABLE it_likp
    FOR ALL ENTRIES IN it_vbrp
    WHERE vbeln = it_vbrp-vgbel.
  READ TABLE it_likp INTO wa_likp WITH KEY vbeln = i_vgbel.
ENDIF.
BREAK PRDSUPPORT2.
SELECT *
  FROM vbak
  INTO TABLE it_vbak
  WHERE vbeln = i_aubel.
 READ TABLE it_vbak INTO wa_vbak INDEX 1.
 lv_auart = wa_vbak-auart.
DATA : gv_bstkd TYPE vbkd-bstkd .
*
*SELECT SINGLE BSTKD
*   FROM VBKD
*   INTO  GV_BSTKD
*   WHERE VBELN = I_AUBEL .
*ENDSELECT .
*LV_PO_NO = GV_BSTKD .
lv_order = i_aubel .
******** "Added by TTL Tushar, On 27.05.2025 11:01:35
*BREAK prdsupport2.
READ TABLE it_vbak INTO wa_vbak WITH KEY auart = 'ZSEZ'.
IF sy-subrc = 0.
  DATA: lt_lines TYPE TABLE OF TLINE,
        lv_name  TYPE THEAD-TDNAME VALUE 'ZDECLARATION'.
   CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        ID                      = 'ST'
        LANGUAGE                = SY-LANGU
        NAME                    = lv_name
        OBJECT                  = 'TEXT'
      TABLES
        LINES                   = lt_lines
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT lt_lines INTO DATA(ls_line).
      lv_declaration = ls_line.
    ENDLOOP.
*    TRANSLATE lv_declaration TO LOWER CASE."++ BY PS dt29.05.2025
  ENDIF.
ENDIF.
******** "Added by TTL Tushar, On 27.05.2025 11:01:35
READ TABLE IT_VBAK INTO WA_VBAK WITH KEY VBELN = I_AUBEL.
IF SY-SUBRC = 0 .
*  lv_order = wa_vbak-bstdk .
  LV_ORDER_DATE = WA_VBAK-ERDAT .
  LV_PO_DATE = WA_VBAK-BSTDK .
ENDIF .
IF it_vbak IS NOT INITIAL.
  SELECT *
    FROM vbap
    INTO TABLE it_vbap
    FOR ALL ENTRIES IN it_vbak
    WHERE vbeln = it_vbak-vbeln.
  SELECT *
    FROM vbpa
    INTO TABLE it_vbpa
    FOR ALL ENTRIES IN it_vbak
    WHERE vbeln = it_vbak-vbeln.
ELSE.
  SELECT *
    FROM ekko
    INTO TABLE it_ekko
    WHERE ebeln = i_aubel.
  READ TABLE it_ekko INTO wa_ekko WITH KEY ebeln = i_aubel.
  IF it_ekko IS NOT INITIAL.
    SELECT *
      FROM ekpo
      INTO TABLE it_ekpo
      FOR ALL ENTRIES IN it_ekko
      WHERE ebeln = it_ekko-ebeln.
  ENDIF.
ENDIF.
READ TABLE it_vbrp INTO wa_vbrp WITH KEY vbeln = i_vbeln.
IF  sy-subrc = 0.
  SELECT SINGLE *
    FROM t001w
    INTO wa_t001w
    WHERE werks = wa_vbrp-werks.
ELSE.
  READ TABLE it_ekko INTO wa_ekko WITH KEY ebeln = i_aubel.
  IF sy-subrc = 0.
    SELECT SINGLE *
      FROM t001w
      INTO wa_t001w
      WHERE werks = wa_ekko-reswk.
  ENDIF.
ENDIF.
*BREAK-POINT .
IF wa_t001w IS NOT INITIAL.
  SELECT SINGLE name1
                str_suppl1
                str_suppl2
                str_suppl3
                city1
                post_code1
    FROM adrc
    INTO (dp_name1 , dp_sup1 , dp_sup2 , dp_sup3 , dp_city1 , dp_post_code1 )
    WHERE addrnumber = wa_t001w-adrnr.
*  break-point .
  IF it_vbak IS NOT INITIAL.
    READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = i_vbeln.
    SELECT SINGLE *
      FROM j_1bbranch
      INTO waj_1bbranch
      WHERE bukrs = wa_vbrk-bukrs
        AND branch = wa_vbrp-werks.
  ELSE.
    SELECT SINGLE *
    FROM j_1bbranch
    INTO waj_1bbranch
    WHERE bukrs = wa_ekko-bukrs
      AND branch = wa_ekko-reswk.
  ENDIF.
  SELECT SINGLE *
    FROM t005u
    INTO wa_t005u
    WHERE spras = 'EN'
      AND land1 = 'IN'
      AND bland = wa_t001w-regio.
ENDIF.
READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = i_vbeln.
IF sy-subrc = 0.
  SELECT SINGLE *
    FROM kna1
    INTO wa_kna1
    WHERE kunnr = wa_vbrk-kunrg.
  SELECT SINGLE *
    FROM adr6
    INTO wa_adr6
    WHERE addrnumber = wa_kna1-adrnr.
*----- Added by Yuvraj on 11.06.2019 -----------*
  SELECT SINGLE *
    FROM knvv
    INTO wa_knvv
    WHERE kunnr EQ wa_kna1-kunnr.
*-----------------------------------------------*
*---------------------Add
*----------- changes by subodh 03 Aug 2018 (GSTIN NO) -------
  SELECT *
   FROM vbpa
   INTO TABLE it_vbpa1
   FOR ALL ENTRIES IN it_vbak
   WHERE vbeln = it_vbak-vbeln AND
         parvw = 'WE'.
  READ TABLE it_vbpa1 INTO wa_vbpa1 WITH KEY vbeln = wa_vbak-vbeln
                                              parvw = 'WE'.
  SELECT SINGLE *
    FROM kna1
    INTO wa_kna2
    WHERE kunnr = wa_vbpa1-kunnr. "wa_vbrk-kunag.
*------ changes by subodh 03 Aug 2018 (PAN NO ship to party) -------
  SELECT SINGLE *
     FROM j_1imocust
     INTO  waj_1imocust1
     WHERE kunnr =  wa_kna2-kunnr.
*----------Above code for GSTIN / PAN by Subodh --------*
*it_vbpa
  BREAK abap4.
  IF it_vbak IS NOT INITIAL.
    READ TABLE it_vbpa INTO wa_vbpa WITH KEY vbeln = i_aubel
                                                 parvw = 'WE'.
    IF sy-subrc = 0.
      SELECT SINGLE *
         FROM kna1
         INTO wa_kna2
         WHERE kunnr = wa_vbpa-kunnr.
      SELECT SINGLE j_1ipanno
        FROM j_1imocust
        INTO i_j_1ipanno
        WHERE kunnr = wa_vbpa-kunnr.
      SELECT SINGLE *
       FROM adr6
       INTO wa_adr7
       WHERE addrnumber = wa_kna2-adrnr.
    ENDIF.
  ELSE.
    SELECT SINGLE *
     FROM kna1
     INTO wa_kna2
     WHERE kunnr = wa_vbrk-kunag.
    SELECT SINGLE j_1ipanno
      FROM j_1imocust
      INTO i_j_1ipanno
      WHERE kunnr = wa_vbrk-kunag.
    SELECT SINGLE *
     FROM adr6
     INTO wa_adr7
     WHERE addrnumber = wa_kna2-adrnr.
  ENDIF.
*BREAK kpitabap.
  SELECT *
    FROM j_1imocust
    INTO TABLE itj_1imocust
    WHERE kunnr =  wa_vbrk-kunrg
      AND kunnr =  wa_vbrk-kunag.
********************Logic for Bill to Party
* SELECT SINGLE name1
*       name2
*       street
*       str_suppl2
*       str_suppl3
*       city1
*       post_code1
*       tel_number
*   FROM adrc
*   INTO wa_bill_to
*   WHERE ADDRNUMBER = wa_kna1-adrnr.
*
*  WA_SHIP_TO = WA_BILL_TO .
*****************************Ship To
*break-point .
  IF it_vbrk IS NOT INITIAL .   "ADDED BY RAHUL 25/04/19
    SELECT * FROM vbpa           "ADDED BY RAHUL 25/04/19
      INTO TABLE lt_vbpa
      WHERE vbeln = i_vbeln.
    READ TABLE lt_vbpa INTO ls_vbpa WITH KEY vbeln = i_vbeln
                                             parvw = 'WE'. "ADDED BY RAHUL 25/04/19
    IF sy-subrc  = 0.
      SELECT SINGLE *
       FROM adrc
       INTO CORRESPONDING FIELDS OF wa_ship_to
       WHERE addrnumber = ls_vbpa-adrnr.    "wa_vbpa-adrnr. "CHANGES REFERRED  BY SESHU 25/04/19
    ENDIF.
  ELSE.
    SELECT SINGLE *
     FROM adrc
     INTO CORRESPONDING FIELDS OF wa_ship_to
     WHERE addrnumber = wa_kna2-adrnr.
  ENDIF.
*BREAK ABAP2.
  IF wa_vbrk-fkart = 'ZGST'.
    CLEAR wa_ship_to.
    READ TABLE it_ekpo INTO wa_ekpo WITH  KEY ebeln = wa_ekko-ebeln.
    IF wa_ekpo-adrnr IS INITIAL.
      IF it_vbrk IS NOT INITIAL .   "ADDED BY RAHUL 25/04/19
        SELECT * FROM vbpa           "ADDED BY RAHUL 25/04/19
         INTO TABLE lt_vbpa
         WHERE vbeln = i_vbeln.
        READ TABLE lt_vbpa INTO ls_vbpa WITH KEY vbeln = i_vbeln
                                                parvw = 'WE'. "ADDED BY RAHUL 25/04/19
        IF sy-subrc  = 0.
          SELECT SINGLE *
           FROM adrc
           INTO CORRESPONDING FIELDS OF wa_ship_to
           WHERE addrnumber = ls_vbpa-adrnr.    "wa_vbpa-adrnr. "CHANGES REFERRED  BY SESHU 25/04/19
        ENDIF.
      ELSE.
        SELECT SINGLE *
         FROM adrc
         INTO CORRESPONDING FIELDS OF wa_ship_to
         WHERE addrnumber = wa_kna2-adrnr.
      ENDIF.
    ELSE.
      SELECT SINGLE *
      FROM adrc
      INTO CORRESPONDING FIELDS OF wa_ship_to
      WHERE addrnumber = wa_ekpo-adrnr.
    ENDIF.
  ENDIF.
********************bILL TO
*break-point .
  SELECT *
    FROM j_1imocust
    INTO TABLE itj_1imocust
    WHERE kunnr =  wa_vbrk-kunrg
      AND kunnr =  wa_vbrk-kunag.
  SELECT SINGLE *
    FROM adrc
    INTO CORRESPONDING FIELDS OF wa_bill_to
    WHERE addrnumber = wa_kna1-adrnr.
*BREAK-POINT .
*CONDENSE : WA_BILL_TO-NAME1 ,
*           WA_BILL_TO-NAME2 ,
*           WA_BILL_TO-STREET ,
*           WA_BILL_TO-STR_SUPPL2 ,
*           WA_BILL_TO-STR_SUPPL3 ,
*           WA_BILL_TO-CITY1 ,
*           WA_BILL_TO-POST_CODE1 .
**append wa_bill to tt_bill .
*WA_BILL-TEXT = WA_BILL_TO-NAME1 .
*IF WA_BILL_TO-NAME1 IS INITIAL .
*  WA_BILL-IND = 'A'.
*ENDIF .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*WA_BILL-TEXT = WA_BILL_TO-NAME2 .
*IF WA_BILL_TO-NAME2 IS INITIAL .
*  WA_BILL-IND = 'A'.
*ENDIF .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*WA_BILL-TEXT = WA_BILL_TO-STREET .
*IF WA_BILL_TO-STREET IS INITIAL .
*  WA_BILL-IND  = 'A'.
*ENDIF .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*WA_BILL-text = WA_BILL_TO-STR_SUPPL2 .
*IF WA_BILL_TO-STR_SUPPL2 IS INITIAL .
*  WA_BILL-IND  = 'A'.
*ENDIF .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*WA_BILL-text = WA_BILL_TO-STR_SUPPL3.
*IF WA_BILL_TO-STR_SUPPL3 IS INITIAL .
*  WA_BILL-IND  = 'A'.
*ENDIF .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*concatenate WA_BILL_TO-CITY1 WA_BILL_TO-POST_CODE1 INTO wa_bill-text  SEPARATED BY SPACE  .
*IF wa_bill-text IS INITIAL .
*  WA_BILL-IND  = 'A'.
*ENDIF .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*concatenate 'Tel No :' WA_BILL_TO-TEL_NUMBER INTO wa_bill-text SEPARATED BY SPACE .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*
*concatenate 'EMail:' WA_ADR6-SMTP_ADDR INTO wa_bill-text SEPARATED BY SPACE  .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*
*
*concatenate 'Tax :' WA_KNA1-STCD3 INTO wa_bill-text  SEPARATED BY SPACE .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*
*concatenate 'GSTIN :' WAJ_1IMOCUST-J_1IPANNO INTO wa_bill-text SEPARATED BY SPACE .
*APPEND WA_BILL TO TT_BILL .
*clear wa_bill .
*
*DELETE TT_BILL WHERE IND = 'A' .
*
*LOOP AT TT_BILL INTO Wa_bill .
*
*  CONCATENATE gv_bill CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            wa_bill-text INTO gv_bill.
*  CONDENSE wa_bill-text  .
*
*ENDLOOP .
*
*shift gv_bill left by 1 places .
*
*read table ITJ_1IMOCUST into waJ_1IMOCUST with key kunnr = WA_VBRK-KUNAG.
*
*CONDENSE : WA_SHIP_TO-NAME1 ,
*           WA_SHIP_TO-NAME2 ,
*           WA_SHIP_TO-STREET ,
*           WA_SHIP_TO-STR_SUPPL2 ,
*           WA_SHIP_TO-STR_SUPPL3 ,
*           WA_SHIP_TO-CITY1 ,
*           WA_SHIP_TO-POST_CODE1 .
*
*WA_SHIP-TEXT = WA_SHIP_TO-NAME1 .
*IF WA_SHIP_TO-NAME1 IS INITIAL .
*  WA_SHIP-IND = 'A'.
*ENDIF .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*WA_SHIP-TEXT = WA_SHIP_TO-NAME2 .
*IF WA_SHIP_TO-NAME2 IS INITIAL .
*  WA_SHIP-IND = 'A'.
*ENDIF .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*WA_SHIP-TEXT = WA_SHIP_TO-STREET .
*IF WA_SHIP_TO-STREET IS INITIAL .
*  WA_SHIP-IND  = 'A'.
*ENDIF .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*WA_SHIP-text = WA_SHIP_TO-STR_SUPPL2 .
*IF WA_SHIP_TO-STR_SUPPL2 IS INITIAL .
*  WA_SHIP-IND  = 'A'.
*ENDIF .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*WA_SHIP-text = WA_SHIP_TO-STR_SUPPL3.
*IF WA_SHIP_TO-STR_SUPPL3 IS INITIAL .
*  WA_SHIP-IND  = 'A'.
*ENDIF .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*concatenate WA_SHIP_TO-CITY1 WA_SHIP_TO-POST_CODE1 INTO wa_SHIP-text  SEPARATED BY SPACE  .
*IF wa_SHIP-text IS INITIAL .
*  WA_SHIP-IND  = 'A'.
*ENDIF .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*concatenate 'Tel No :' WA_SHIP_TO-TEL_NUMBER INTO wa_SHIP-text SEPARATED BY SPACE .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*
*concatenate 'EMail:' WA_ADR7-SMTP_ADDR INTO wa_SHIP-text SEPARATED BY SPACE  .
*APPEND WA_SHIP TO TT_SHIP .
*clear wa_SHIP .
*
*
*
*DELETE TT_SHIP WHERE IND = 'A' .
*
*LOOP AT TT_SHIP INTO Wa_SHIP .
*
*  CONCATENATE gv_SHIP CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            wa_SHIP-text INTO gv_SHIP.
*  CONDENSE wa_SHIP-text  .
*
*ENDLOOP .
*
*shift gv_SHIP left by 1 places .
*
*
*CONDENSE : DP_NAME1 , DP_SUP1 , DP_SUP2 , DP_SUP3 , DP_CITY1 , DP_POST_CODE1 .
*
*WA_DP-TEXT = DP_NAME1 .
*IF DP_NAME1 IS INITIAL .
*  WA_DP-IND = 'A'.
*ENDIF .
*APPEND WA_DP TO TT_DP .
*clear WA_DP .
*WA_DP-TEXT = DP_SUP1 .
*IF DP_SUP1 IS INITIAL .
*  WA_DP-IND = 'A'.
*ENDIF .
*APPEND WA_DP TO TT_DP .
*clear WA_DP .
*WA_DP-TEXT =  DP_SUP2 .
*IF  DP_SUP2  IS INITIAL .
*  WA_DP-IND  = 'A'.
*ENDIF .
*APPEND WA_DP TO TT_DP .
*clear WA_DP .
*WA_DP-text = DP_SUP3 .
*IF DP_SUP3 IS INITIAL .
*  WA_DP-IND  = 'A'.
*ENDIF .
*APPEND WA_DP TO TT_DP .
*clear WA_DP .
*concatenate DP_CITY1 DP_POST_CODE1  INTO WA_DP-text  SEPARATED BY SPACE  .
*IF WA_DP-text IS INITIAL .
*  WA_DP-IND  = 'A'.
*ENDIF .
*APPEND WA_DP TO TT_DP .
*clear WA_DP .
*
*
*
*DELETE TT_DP WHERE IND = 'A' .
*
*LOOP AT TT_DP INTO WA_DP .
*
*  CONCATENATE gv_DP CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            WA_DP-text INTO gv_DP.
*  CONDENSE WA_DP-text  .
*
*ENDLOOP .
*
*shift gv_DP left by 1 places .
*
*
*break-point.
*  break-point .
  SELECT SINGLE smtp_addr
   FROM adr6
   INTO gv_email
   WHERE addrnumber = wa_kna1-adrnr
   AND consnumber = '001' .
*  BREAK kpitabap.
*IF it_vbak IS NOT INITIAL.   "Commented By Rahul 25/04/19
*  READ TABLE it_vbpa INTO wa_vbpa WITH KEY vbeln = I_AUBEL
*                                             PARVW = 'WE'. "Commented by rahul 25/04/19
  IF it_vbrk IS NOT INITIAL.   "ADDED BY RAHUL 25/04/19
    SELECT * FROM vbpa           "ADDED BY RAHUL 25/04/19
      INTO TABLE lt_vbpa
      WHERE vbeln = i_vbeln.
    READ TABLE lt_vbpa INTO ls_vbpa WITH KEY vbeln = i_vbeln
                                             parvw = 'WE'. "ADDED BY RAHUL 25/04/19
    IF sy-subrc  = 0.
      SELECT SINGLE *
       FROM adrc
       INTO wa_shipt
       WHERE addrnumber = ls_vbpa-adrnr.    "wa_vbpa-adrnr. "CHANGES REFERRED  BY SESHU 25/04/19
    ENDIF.
  ELSE.
    SELECT SINGLE *
     FROM adrc
     INTO wa_shipt
     WHERE addrnumber = wa_kna2-adrnr.
  ENDIF.
*------ Changes by subodh 20 Nov 2018 -------*
*--changes for place of supply fetch from shipt to party ---*
  SELECT SINGLE *
         FROM t005u
         INTO ls_t005u
         WHERE spras = wa_shipt-langu AND
               land1 = wa_shipt-country AND
               bland = wa_shipt-region.
  r_name = wa_vbrk-vbeln.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = 'Z019'
      language                = 'E'
      name                    = r_name
      object                  = 'VBBK'
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
* IMPORTING
*     HEADER                  =
*     OLD_LINE_COUNTER        =
    TABLES
      lines                   = it_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  READ TABLE it_lines INTO wa_lines INDEX 1.
  i_hypo = wa_lines-tdline.
ENDIF.
*break-point .
*************** TEMPLATE CODE HEADER WINDOW (TEMPLATE)
*****************Code for header data
SELECT SINGLE bstkd
   FROM vbkd
   INTO  gv_bstkd
   WHERE vbeln = i_aubel .
IF sy-subrc = 0 .
*  BREAK-POINT .
  lv_po_no = gv_bstkd .
ENDIF .
*endif .
""""""""""''BEGIN OF CODE ADDED BY KALYANI ON 05.12.2023
SELECT SINGLE inco1 inco2 FROM vbkd                "ADDED INCO1 ON 12.12.2023
  INTO ( gv_inco1,gv_inco2 ) WHERE
  vbeln = i_aubel.
IF gv_inco1 IS NOT INITIAL AND gv_inco2 IS NOT INITIAL.
  IF gv_inco1 = 'EXW'.
    CONCATENATE 'EX Works' gv_inco2 INTO gv_inco SEPARATED BY ''.
    lv_incoterm = gv_inco.
  ELSE.
    lv_incoterm = gv_inco1.
  ENDIF.
ENDIF.
"""""""""END OF CODE ADDED BY KALYANI ON 05.12.2023
**************************"Added by OCPL Tushar Tayade on 13.12.2023 12:48:02
*BREAK PRDSUPPORT2.
DATA: tdname    TYPE thead-tdname,
      it_result TYPE TABLE OF tline.
tdname = i_aubel.
CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id              = '0023'
    language        = sy-langu
    name            = tdname
    object          = 'VBBK'
*IMPORTING
*HEADER = HTEXT
  TABLES
    lines           = it_result "LTEXT
  EXCEPTIONS
    id              = 1
    language        = 2
    name            = 3
    not_found       = 4
    object          = 5
    reference_check = 6.
*DATA: LV_LINE TYPE STRING,
*      LV_LINE1 TYPE STRING.
LOOP AT it_result INTO DATA(wa_result).
  lv_line = wa_result-tdline.
  CONCATENATE lv_line1 lv_line INTO lv_line1 SEPARATED BY ' '.
  CLEAR lv_line.
ENDLOOP.
CONDENSE lv_line1.            "ADDED BY KALYANI ON 28.12.2023
*******************"Ended by OCPL Tushar Tayade on 13.12.2023 12:48:02
lv_order = i_aubel .
*READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = i_vbeln.
*IF sy-subrc = 0.
*READ TABLE it_vbrp INTO wa_vbrp WITH KEY vbeln = wa_vbrk-vbeln.
*IF sy-subrc = 0 .
*READ TABLE it_vbak INTO wa_vbak WITH KEY vbeln = wa_vbrp-aubel.
*IF sy-subrc = 0 .
*LV_PO_NO = wa_vbak-bstnk.
*lv_po_date = wa_vbak-bstdk.
*lv_order = wa_vbrp-aubel.
*lv_order_date = wa_vbak-bstdk.
*ELSE.
**LV_PO_NO = wa_ekko-ebeln.
*lv_po_date = wa_ekko-aedat.
*ENDIF.
lv_del_no = wa_vbrp-vgbel.
lv_inv_no = i_vbeln.
lv_invoice_date = wa_vbrk-fkdat.
**++ by ps dt 29.05.2025
*
*select single vbeln
*              vbtyp_v
*              vbelv from vbfa INTO wa_vbfa
*              WHERE vbeln = i_vbeln and vbtyp_v = 'C' .
*if sy-subrc = 0.
*select single  auart from vbak INTO LV_AUART where  vbeln = wa_vbfa-vbelv.
*endif.
**-- by ps dt 29.05.2025
"Dispatch From :
CONCATENATE wa_plant-name1 wa_plant-str_suppl1 wa_plant-str_suppl2 wa_plant-str_suppl3 wa_plant-city1 '-'  wa_plant-post_code1 INTO lv_disp_from SEPARATED BY space.
"GSTIN : &WAJ_1BBRANCH-GSTIN(C)&
"Billed to :
"Billed to :
"Customer Code : &WA_KNA1-kunnr(C)&
CONCATENATE wa_billp-name1 wa_billp-name2 wa_billp-street wa_billp-str_suppl2 wa_billp-str_suppl3 wa_billp-city1 '-' wa_billp-post_code1 INTO lv_billed_to SEPARATED BY space.
"Tel : &WA_BILLP-TEL_NUMBER(C)&
"E-Mail : &WA_ADR6-SMTP_ADDR(C)&
"GSTIN : &WA_KNA1-STCD3(C)&
"PAN No. : &WAJ_1IMOCUST-J_1IPANNO(C)&
"&I_HYPO(C)&
"Shipped to :
"Customer Code : &WA_KNA2-kunnr(C)&
"&WA_SHIPT-name1(C)& &WA_SHIPT-name2(C)& &WA_SHIPT-street(C)& &WA_SHIPT-str_suppl2(C)& &WA_SHIPT-str_suppl3(C)&  &WA_SHIPT-city1(C)& &WA_SHIPT-city2(C)& &LS_T005U-BEZEI(C)&
"&WA_SHIPT-post_code1(C)&
"Tel : &WA_SHIPT-TEL_NUMBER(C)&
"E-Mail : &WA_ADR7-SMTP_ADDR(C)&
"GSTIN : <C2>&WA_KNA2-STCD3(C)&</>
"PAN No. : <C2>&I_J_1IPANNO(C)&</>
"PAN No. : <C2>&I_J_1IPANNO(C)&</>
"<C2>&WAJ_1IMOCUST1-J_1IPANNO(C)&</>
CONCATENATE wa_shipt-name1 wa_shipt-name2 wa_shipt-street wa_shipt-str_suppl2 wa_shipt-str_suppl3 wa_shipt-city1 '-' wa_shipt-city2 ls_t005u-bezei '-' wa_shipt-post_code1 INTO lv_shipped_to SEPARATED BY space.
" Place Of Supply : &ls_T005U-BEZEI&
READ TABLE itj_1imocust INTO waj_1imocust WITH KEY kunnr = wa_vbrk-kunrg.
*ENDIF.
************* SAME HEADER TEMPLATE code 2
"%CODE6 (SAME TEMPLATE)
READ TABLE itj_1imocust INTO waj_1imocust WITH KEY kunnr = wa_vbrk-kunag.
IF it_vbak IS NOT INITIAL.
  wa_kna2-kunnr = wa_vbpa-kunnr.
ENDIF.
READ TABLE itj_1imocust INTO waj_1imocust WITH KEY kunnr = wa_vbrk-kunrg.
*ENDIF.
*INPUT PARAMETERS
*ITJ_1IMOCUST
*WA_VBRK
*IT_VBAK
*WA_VBPA
*
*OUTPUT PARAMETERS
*WAJ_1IMOCUST
*WA_KNA2
LOOP AT it_vbrp INTO wa_vbrp.    "ADDED BY VVK
  wa_final-matnr = wa_vbrp-matnr.
  wa_final-arktx = wa_vbrp-arktx.
*--------------------------------------------------------------
  IF i_vbeln IS NOT INITIAL.
    SELECT *
      FROM vbrk
      INTO TABLE it_vbrk_11
      WHERE vbeln = i_vbeln.
  ENDIF.
*BREAK abap4.
  LOOP AT it_vbrk_11 INTO wa_vbrk_11.
    SELECT SINGLE kdmat
      FROM knmt
      INTO lv_kdmat
      WHERE matnr = wa_vbrp-matnr
      AND vkorg =   wa_vbrk_11-vkorg
      AND vtweg =   wa_vbrk_11-vtweg
      AND kunnr =   wa_vbrk_11-kunrg.
  ENDLOOP.
  IF lv_kdmat IS NOT INITIAL.
    wa_final-kdmat = lv_kdmat.
    CLEAR lv_kdmat.
  ENDIF.
*--------------------------------------------------------------
**++Begin of code added by abhijit d on 15.11.2023 to Sales Text on Invoice.
*  TR#  SQSK903745.
  IF wa_vbrk-vkorg = '4850'.
    BREAK prdsupport.
    DATA  : lv_desc TYPE string.
    gv_object        = 'VBBP'.
    gv_id            = '0001'.
    CONCATENATE wa_vbak-vbeln wa_vbrp-posnr INTO gv_longtext_name.
    gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        object                  = gv_object
        id                      = gv_id
        language                = gv_langu
        name                    = gv_longtext_name "TR
      IMPORTING
        header                  = textheader
      TABLES
        lines                   = textlines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    LOOP AT textlines.
      CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
    ENDLOOP.
    lv_desc = text.
    IF lv_desc IS NOT INITIAL.
      CONCATENATE wa_final-matnr '/' lv_desc "'/' WA_FINAL-KDMAT
      INTO wa_final-desc SEPARATED BY space.
    ELSE.
      CONCATENATE wa_final-matnr '/' wa_final-arktx "'/' WA_FINAL-KDMAT
    INTO wa_final-desc SEPARATED BY space.
    ENDIF.
    CLEAR : lv_desc, text , gv_object, gv_id, gv_longtext_name.
  ELSE.
**++End of code added by abhijit d on 15.11.2023 to Sales Text on Invoice.
    IF wa_final-kdmat IS NOT INITIAL.
      CONCATENATE wa_final-matnr '/' wa_final-arktx "'/' WA_FINAL-KDMAT
      INTO wa_final-desc SEPARATED BY space.
    ELSE.
      CONCATENATE wa_final-matnr '/' wa_final-arktx
      INTO wa_final-desc SEPARATED BY space.
    ENDIF.
  ENDIF.
  wa_final-quantity = wa_vbrp-fklmg.   "ADDED BY VVK
  wa_final-unit = wa_vbrp-meins.          "ADDED BY VVK
***********MAIN WINDOW CODE 1 **********
  sr_no = sr_no + 1.
  wa_final-sr_no = sr_no.       "ADDED BY VVK
  CLEAR : wa_ser01, it_objk[], wa_objk.
*break abap4.
*break-point .
  IF wa_vbrp-vgbel IS NOT INITIAL.
    SELECT SINGLE *
      FROM ser01
      INTO wa_ser01
      WHERE lief_nr = wa_vbrp-vgbel
        AND posnr = wa_vbrp-vgpos.
    IF sy-subrc = 0.
      SELECT *
        FROM objk
        INTO TABLE it_objk
        WHERE obknr = wa_ser01-obknr.
    ENDIF.
    IF sy-subrc = 0.
      temp = 'Serial No('.
      LOOP AT it_objk INTO wa_objk.
        CONCATENATE seri wa_objk-sernr INTO seri SEPARATED BY ','.
      ENDLOOP.
      CONCATENATE temp seri ')' INTO i_sernr.
      wa_final-i_sernr = i_sernr.
    ENDIF.
  ENDIF.
  CLEAR textheader.
*DATA : WA_VBRK TYPE VBRK.
*DATA : I_FKART TYPE FKART.
*DATA : NAME TYPE STRING.
*DATA : TEXT TYPE  STRING.
*DATA : GI_LONGTEXT      TYPE STANDARD TABLE OF TLINE WITH HEADER LINE ,
*       GI_LONGTEXT_SER  TYPE STANDARD TABLE OF TLINE WITH HEADER LINE ,
*       GV_OBJECT        TYPE THEAD-TDOBJECT ,"VALUE 'Object name',
*       GV_ID            TYPE THEAD-TDID ," VALUE 'ID Name',
*       GV_LONGTEXT_NAME TYPE THEAD-TDNAME,"  VALUE 'LongText Name',
*       GV_LANGU         TYPE THEAD-TDSPRAS ,
*       GV_count         TYPE I.
*break abap2.
  CLEAR : i_vcbc,i_vcbc_desc,i_challan_no,i_challan_date,
          i_body_serno ,i_chassis_no,i_engine_no,i_fkart.
  IF wa_vbrp-vbeln IS NOT INITIAL.
    name = wa_vbrp-vbeln.
  ENDIF.
  IF wa_vbrp-vbeln IS NOT INITIAL.
    SELECT SINGLE * FROM vbrk INTO wa_vbrk WHERE vbeln =  wa_vbrp-vbeln.
    IF sy-subrc = 0.
      i_fkart = wa_vbrk-fkart.
    ENDIF.
  ENDIF.
****addition
*data: l_name type TDOBNAME."TR
  l_name = name."TR
  gv_object        = 'VBBK'.
  gv_id            = 'ZVCB'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_vcbc = text.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
*-------------------------------VCBC DESCRIPTION-------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZDES'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_vcbc_desc = text.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**------------------------------CHALLAN NO---------------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZCHN'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_challan_no = text.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**----------------------------CHALLAN DATE-----------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZCHD'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_challan_date = text.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**---------------------------BODY SERIAL NO---------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZBOD'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_body_serno = text.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**-----------------------CHASSIS NO---------------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZCHA'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_chassis_no = text.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**--------------------------------ENGINE_NO.--------------
*
  gv_object        = 'VBBK'.
  gv_id            = 'ZENG'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_engine_no = text.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*
*ENDFUNCTION.
**-------------------------------------------------------
*BREAK-POINT .
*BREAK-POINT .
*BREAK-POINT .
*BREAK ABAP4.
  wa_text-text = wa_final-desc .
  IF wa_final-desc  IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
  wa_text-text = wa_final-kdmat .      " ADDED BY DEEPAK
  CONCATENATE 'Customer-Material Part Number :' wa_text-text INTO wa_text-text SEPARATED BY space.
  IF wa_final-kdmat  IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
  wa_text-text = i_sernr .
  IF i_sernr   IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
*wa_text-text = i_vcbc .
*  CONCATENATE 'VCBC' ':' I_VCBC INTO WA_TEXT-TEXT SEPARATED BY SPACE . " code commented by abhijitd on 17.11.2023
*  WA_TEXT-TEXT = I_VCBC. "added by abhijit d on 17.11.2023. TR#SQSK903753
  CONDENSE i_vcbc .
  IF i_vcbc   IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
  CONCATENATE 'VCBC Descp' ':' i_vcbc_desc INTO wa_text-text SEPARATED BY space .
  CONDENSE i_vcbc_desc .
  IF i_vcbc_desc   IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
*wa_text-text = I_VCBC_DESC .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
  CONCATENATE 'Challan No.' ':' i_challan_no  INTO wa_text-text SEPARATED BY space .
  CONDENSE i_challan_no  .
  IF i_challan_no  IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
*wa_text-text = I_CHALLAN_NO .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
  CONCATENATE 'Challan Date' ':' i_challan_date INTO wa_text-text SEPARATED BY space .
  CONDENSE i_challan_date .
  IF i_challan_date IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
*wa_text-text = I_CHALLAN_DATE .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
*wa_text-text = I_BODY_SERNO .
  CONCATENATE 'Body Serial No.' ':' i_body_serno  INTO wa_text-text SEPARATED BY space .
  CONDENSE i_body_serno  .
  IF i_body_serno  IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
*break-point .
  CONCATENATE 'Chassis No' ':' i_chassis_no INTO wa_text-text SEPARATED BY space .
*data : len type i .
  CONDENSE i_chassis_no  .
*len = strlen( I_CHASSIS_NO ) .
  IF i_chassis_no IS INITIAL .
    wa_text-ind = 'A' .
  ENDIF .
*DATA : GV_CHASSIS TYPE STRING .
*if len = '2' .
*   wa_text-ind = 'A' .
*endif .
*GV_CHASSIS = I_CHASSIS_NO .
*if GV_CHASSIS IS INITIAL .
* wa_text-ind = 'A' .
*endif .
*wa_text-text = I_CHASSIS_NO.
  APPEND wa_text TO it_text .
  CLEAR wa_text .
* wa_text-text = I_ENGINE_NO .
  CONCATENATE 'Engine No.' ':' i_engine_no INTO wa_text-text SEPARATED BY space .
  CONDENSE i_engine_no .
  IF i_engine_no   = ' '.
    wa_text-ind = 'A' .
  ENDIF .
  APPEND wa_text TO it_text .
  CLEAR wa_text .
  DELETE it_text WHERE ind = 'A' .
  LOOP AT it_text INTO wa_text .
    CONCATENATE wa_final-descp cl_abap_char_utilities=>newline
              wa_text-text  INTO wa_final-descp .
    CONDENSE wa_final-descp .
  ENDLOOP .
  SHIFT wa_final-descp BY 1 PLACES RIGHT IN CHARACTER MODE .
*break-point .
*  BREAK ABAP4.
  REFRESH it_text[].       "COMMENTED BY DEEPAK
  CLEAR wa_text .
  CLEAR i_sernr .
  CLEAR i_vcbc .
  CLEAR i_vcbc_desc .
  CLEAR i_challan_no  .
  CLEAR i_challan_date .
  CLEAR i_body_serno  .
  CLEAR i_chassis_no  .
  CLEAR i_engine_no .
*
*CONCATENATE wa_final-desc CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            wa_final-I_SERNR CL_ABAP_CHAR_UTILITIES=>NEWLINE I_VCBC INTO wa_final-descp .
*condense wa_final-descp .
*
*CONCATENATE wa_final-descp CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            wa_final-I_SERNR CL_ABAP_CHAR_UTILITIES=>NEWLINE I_VCBC INTO wa_final-descp .
*condense wa_final-descp .
*
*CONCATENATE wa_final-descp CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            wa_final-I_SERNR CL_ABAP_CHAR_UTILITIES=>NEWLINE I_VCBC INTO wa_final-descp .
*
*CONCATENATE wa_final-desc CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            wa_final-I_SERNR CL_ABAP_CHAR_UTILITIES=>NEWLINE I_VCBC
*            CL_ABAP_CHAR_UTILITIES=>NEWLINE I_VCBC_DESC
*            CL_ABAP_CHAR_UTILITIES=>NEWLINE I_CHALLAN_NO
*            CL_ABAP_CHAR_UTILITIES=>NEWLINE I_CHALLAN_DATE
*            CL_ABAP_CHAR_UTILITIES=>NEWLINE I_BODY_SERNO
*            CL_ABAP_CHAR_UTILITIES=>NEWLINE I_CHASSIS_NO
*            CL_ABAP_CHAR_UTILITIES=>NEWLINE I_ENGINE_NO INTO wa_final-descp .
********SANJU
*  WA_FINAL-C_SR_NO = WA_FINAL-SR_NO .
*  CONDENSE  WA_FINAL-C_SR_NO .
*CONCATENATE WA_FINAL-C_SR_NO CL_ABAP_CHAR_UTILITIES=>NEWLINE
*            wa_final-I_SERNR INTO WA_FINAL-SERIAL .
*********** MAIN WINDOW CODE 2************
*break abap2.
  CLEAR : i_vcbc,i_vcbc_desc,i_challan_no,i_challan_date,
          i_body_serno ,i_chassis_no,i_engine_no,i_fkart.
  IF wa_vbrp-vbeln IS NOT INITIAL.
    name = wa_vbrp-vbeln.
  ENDIF.
  IF wa_vbrp-vbeln IS NOT INITIAL.
    SELECT SINGLE * FROM vbrk INTO wa_vbrk1 WHERE vbeln =  wa_vbrp-vbeln.
    IF sy-subrc = 0.
      i_fkart = wa_vbrk1-fkart.
    ENDIF.
  ENDIF.
  l_name = name."TR
  gv_object        = 'VBBK'.
  gv_id            = 'ZVCB'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_vcbc = text.
  IF i_fkart = 'ZM72'.                    "*****condition on text in smartform
    wa_final-vcbc = i_vcbc.
  ENDIF.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
*-------------------------------VCBC DESCRIPTION-------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZDES'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_vcbc_desc = text.
  IF i_fkart = 'ZM72'.
    wa_final-vcbc_desc = i_vcbc_desc.
  ENDIF.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**------------------------------CHALLAN NO---------------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZCHN'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_challan_no = text.
  IF i_fkart = 'ZM72'.
    wa_final-i_challan_no = i_challan_no.
  ENDIF.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**----------------------------CHALLAN DATE-----------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZCHD'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_challan_date = text.
  IF i_fkart = 'ZM72'.
    wa_final-i_challan_date = i_challan_date.
  ENDIF.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**---------------------------BODY SERIAL NO---------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZBOD'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_body_serno = text.
  IF i_fkart = 'ZM72'.
    wa_final-i_body_serno = i_body_serno.
  ENDIF.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**-----------------------CHASSIS NO---------------------------------
  gv_object        = 'VBBK'.
  gv_id            = 'ZCHA'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_chassis_no = text.
  IF i_fkart = 'ZM72'.
    wa_final-i_chasis_no = i_chassis_no.
  ENDIF.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*ENDFUNCTION.
**--------------------------------ENGINE_NO.--------------
*
  gv_object        = 'VBBK'.
  gv_id            = 'ZENG'.
  gv_longtext_name = l_name.
  gv_langu         = sy-langu+0(1).
*-----------------------------------------------------
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      object                  = gv_object
      id                      = gv_id
      language                = gv_langu
      name                    = gv_longtext_name "TR
    IMPORTING
      header                  = textheader
    TABLES
      lines                   = textlines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  LOOP AT textlines.
    CONCATENATE text textlines-tdline INTO text SEPARATED BY space.
  ENDLOOP.
  i_engine_no = text.
  IF i_fkart = 'ZM72'.
    wa_final-i_engine_no = i_engine_no.
  ENDIF.
  CLEAR  : text, textheader,textlines.
  FREE : textlines.
  CLEAR  : gv_object  ,
           gv_id  ,
           gv_longtext_name ,
           gv_langu .
*
*ENDFUNCTION.
**-------------------------------------------------------
*INPUT PARAMETER
*I_CHALLAN_DATE
*I_BODY_SERNO
*I_CHASSIS_NO
*I_ENGINE_NO
*I_FKART
*WA_VBRK1
*IT_VBRK
*
*OUTPUT PARAMETER
*I_CHALLAN_NO
*I_CHALLAN_DATE
*I_BODY_SERNO
*I_CHASSIS_NO
*I_ENGINE_NO
*I_FKART
*WA_VBRK1
*IT_VBRK
***********MAIN WINDOW CODE3******88
  SELECT SINGLE steuc
    FROM marc
    INTO hsn_sac
    WHERE matnr = wa_vbrp-matnr AND
          werks = wa_vbrp-werks.      "added by Rahul 06/05/19
  CLEAR : k007_valu.
  wa_final-hsc_code = hsn_sac.
*READ TABLE it_vbrk INTO wa_vbrk INDEX 1.
  READ TABLE it_konv INTO wa_konv WITH KEY kposn = wa_vbrp-posnr
                                           kschl = 'K007'.
  IF sy-subrc = 0.
    k007_valu = ( -1 ) * wa_konv-kwert.
* CONCATENATE wa_konv-kwert '-' INTO K007_valu .
  ENDIF.
  READ TABLE it_konv INTO wa_konv WITH KEY kposn = wa_vbrp-posnr
                                           kschl = 'ZF01'.
  IF sy-subrc = 0.
    wa_vbrp-netwr = wa_vbrp-netwr - wa_konv-kwert.
  ENDIF.
  "ADD START BY RUKESH IN TP ON 21.09.2022
  READ TABLE it_konv INTO wa_konv WITH KEY kposn = wa_vbrp-posnr
                                           kschl = 'ZBR0'.
  IF sy-subrc = 0.
    wa_vbrp-netwr = wa_vbrp-netwr - wa_konv-kwert.
  ENDIF.
  "ADD END BY RUKESH IN TP ON 21.09.2022
  rate = ( wa_vbrp-netwr + k007_valu ) / wa_vbrp-fklmg.
  total = rate * wa_vbrp-fklmg."wa_vbrp-netwr + K007_valu. "* wa_vbrp-fklmg.
  f_total = f_total + total - k007_valu.
*   BREAK ABAP2.
*** BEGIN OF CODE ADDED BY OCPL APARNA PHALKE ON 15.02.2023******
  IF i_fkart = 'ZM72'.
    READ TABLE it_vbrk INTO wa_vbrk WITH  KEY vbeln = wa_vbrp-vbeln.
    READ TABLE lt_table INTO DATA(ls_table) WITH KEY kunag = wa_vbrk-kunag
                                                      kschl = 'ZP01'.
    IF sy-subrc = 0.
      CLEAR : rate , total ,f_total.
      rate = ls_table-netwr.
      total = rate * wa_vbrp-fklmg.
      f_total = f_total + total - k007_valu.
    ENDIF.
  ENDIF.
*********END OF CODE BY APARNA PHALKE ON 15.02.2023************
  wa_final-rate = rate.          "ADDED BY VIVEK
  wa_final-tot_amt = total.      "ADDED BY VIVEK
  APPEND wa_final TO it_final.
  CLEAR wa_final.
*INPUT PARAMETERS
*WA_VBRP
*IT_VBRK
*IT_KONV
*WA_KONV
*K007_VALU
*WA_FINAL
*
*OUTPUT PARAMETERS
*HSN_SAC
*TOTAL
*RATE
*F_TOTAL
*WA_FINAL
*IT_FINAL
************ MAIN WINDOW FOOTER CODE 1****************************
  CLEAR wa_vbrk2.
  READ TABLE it_vbrk INTO wa_vbrk2 INDEX 1.
  id       = 'ZCHA'.
  language = 'EN'.
  name     = wa_vbrk2-vbeln.
  object   = 'VBBK'.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = id
      language                = language
      name                    = name
      object                  = object
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
* IMPORTING
*     HEADER                  =
*     OLD_LINE_COUNTER        =
    TABLES
      lines                   = it_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  READ TABLE it_lines INTO wa_lines INDEX 1.
  IF sy-subrc = 0.
    chassis = wa_lines-tdline.
  ENDIF.
  FREE : it_lines, wa_lines, id.
  id = 'ZENG'.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = id
      language                = language
      name                    = name
      object                  = object
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
* IMPORTING
*     HEADER                  =
*     OLD_LINE_COUNTER        =
    TABLES
      lines                   = it_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  READ TABLE it_lines INTO wa_lines INDEX 1.
  IF  sy-subrc = 0.
    engine = wa_lines-tdline.
  ENDIF.
*INPUT PARAMETER
*NA
*
*OUTPUT PARAMETER
*CHASSIS
*ENGINE
********************* MAIN TABLE FOOTER CODE 2****************
  CLEAR : k007_valu.
  amt = f_total.
  CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
    EXPORTING
      amt_in_num         = amt
    IMPORTING
      amt_in_words       = f_total_txt
    EXCEPTIONS
      data_type_mismatch = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*BREAK-POINT .
*BREAK kpitabap.
*BREAK-POINT .
  IF igst_valu IS NOT INITIAL.
    CLEAR : amt.
    amt = igst_valu." + F_TOTAL.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = amt
      IMPORTING
        amt_in_words       = igst_valu_txt
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
  ENDIF.
  IF cgst_valu IS NOT INITIAL.
    CLEAR : amt.
    amt = cgst_valu." + F_TOTAL.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = amt
      IMPORTING
        amt_in_words       = cgst_valu_txt
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
  ENDIF.
  IF sgst_valu IS NOT INITIAL.
    CLEAR : amt.
    amt = sgst_valu." + F_TOTAL.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = amt
      IMPORTING
        amt_in_words       = sgst_valu_txt
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
  ENDIF.
  IF zf01_valu IS NOT INITIAL.
    CLEAR : amt.
    amt = zf01_valu." + F_TOTAL.
    CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
      EXPORTING
        amt_in_num         = amt
      IMPORTING
        amt_in_words       = zf01_valu_txt
      EXCEPTIONS
        data_type_mismatch = 1
        OTHERS             = 2.
    TRANSLATE zf01_valu_txt TO UPPER CASE.
  ENDIF.
*G_TOTAL = IGST_VALU + CGST_VALU + SGST_VALU + F_TOTAL + TCS_VALUE + ZINT_VALU + ZF01_VALU." + K007_VALU.
*IF G_TOTAL IS NOT INITIAL.
*
*CLEAR : amt.
*amt = G_TOTAL." + F_TOTAL.
*CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
*  EXPORTING
*    amt_in_num               = amt
*  IMPORTING
*    AMT_IN_WORDS             = G_TOT_TEXT
*  EXCEPTIONS
*    DATA_TYPE_MISMATCH       = 1
*    OTHERS                   = 2
*          .
*IF wa_vbrk-waerk = 'INR' .
*TRANSLATE G_TOT_TEXT TO UPPER CASE.
*
*elseif wa_vbrk-waerk = 'USD'.
**  REPLACE  'RUPEES' IN G_TOT_TEXT WITH 'AND'.
**  REPLACE  'PAISE' IN G_TOT_TEXT WITH 'CENT'.
*  REPLACE 'Rupees' WITH 'USD' INTO G_TOT_TEXT.
*  REPLACE 'Paise' WITH 'Cent' INTO G_TOT_TEXT.
*  REPLACE 'Paise' WITH 'Cent' INTO G_TOT_TEXT.
*  TRANSLATE G_TOT_TEXT TO UPPER CASE.
*ENDIF.
*ENDIF.
*IMPORT PARAMETER
*K007_VALU
*
*OUTPUT PARAMETER
*F_TOTAL_TXT
*IGST_RATE
*CGST_RATE
*SGST_RATE
*IGST_VALU
*CGST_VALU
*SGST_VALU
*IGST_VALU_TXT
*CGST_VALU_TXT
*SGST_VALU_TXT
*G_TOTAL
*G_TOT_TEXT
*TCS_RATE
*TCS_VALUE
*K007_RATE
*K007_VALU
*ZINT_RATE
*ZINT_VALU
*ZF01_RATE
*ZF01_VALU
*ZF01_VALU_TXT
*WA_VBRK
ENDLOOP.
CLEAR igst_valu .
CLEAR cgst_valu .
CLEAR sgst_valu .
LOOP AT it_konv INTO wa_konv.
*  BREAK-POINT .
  IF wa_konv-kschl = 'JOIG'.
    igst_rate = wa_konv-kbetr / 10.
    igst_valu = igst_valu + wa_konv-kwert.
*    BREAK-point .
  ENDIF.
  IF wa_konv-kschl = 'JOCG'.
    cgst_rate = wa_konv-kbetr / 10.
    cgst_valu = cgst_valu + wa_konv-kwert.
  ENDIF.
  IF wa_konv-kschl = 'JOSG'.
    sgst_rate = wa_konv-kbetr / 10.
    sgst_valu = sgst_valu + wa_konv-kwert.
  ENDIF.
*  break abap4.
  IF wa_konv-kschl = 'ZTCS'.
    tcs_rate  = wa_konv-kbetr / 10.
    tcs_value = tcs_value + wa_konv-kwert.
  ENDIF.
  "----- ADDED BY YUVRAJ 19.11.2020 FOR JTC1&JTC2
*    IF WA_KONV-KSCHL = 'JTC1'.
*     JTC1_RATE  = WA_KONV-KBETR / 10.
*     JTC1_VALUE = JTC1_VALUE + WA_KONV-KWERT.
*    ENDIF.
*    IF WA_KONV-KSCHL = 'JTC2'.
*     JTC2_RATE  = WA_KONV-KBETR / 10.
*     JTC2_VALUE = JTC2_VALUE + WA_KONV-KWERT.
*    ENDIF.
  "----- ADDED BY YUVRAJ 19.11.2020 FOR JTC1&JTC2
  IF wa_konv-kschl = 'K007'.
    k007_rate  = wa_konv-kbetr / 10.
    k007_valu = k007_valu + wa_konv-kwert.
  ENDIF.
  IF wa_konv-kschl = 'ZINT'.
    zint_rate  = wa_konv-kbetr / 10.
    zint_valu = zint_valu + wa_konv-kwert.
  ENDIF.
  IF wa_konv-kschl = 'ZF01'.
    lv_kschl = wa_konv-kschl.
    zf01_rate  = wa_konv-kbetr / 10.
    zf01_valu = zf01_valu + wa_konv-kwert.
******LOGIC ADDED BY APARNA PHALKE ON 14.02.2023***********
    READ TABLE it_vbrk INTO wa_vbrk WITH KEY vbeln = i_vbeln.
    IF wa_vbrk-fkart = 'ZM72'.
      READ TABLE lt_table INTO ls_table WITH KEY fkart = wa_vbrk-fkart
                                                       kunag = wa_vbrk-kunag.
      lv_descrip = ls_table-ztext.
      zf01_valu = ls_table-netwr.
    ENDIF.
*******ENDED BY LOGIC APARNA PHALKE ON 14.02.2023***************
  ENDIF.
  CLEAR wa_konv .
ENDLOOP.
*BREAK abap2.
g_total = igst_valu + cgst_valu + sgst_valu + f_total + tcs_value + zint_valu + zf01_valu + jtc1_value + jtc2_value.
BREAK abap3.
IF g_total IS NOT INITIAL.
  CLEAR : amt.
  amt = g_total." + F_TOTAL.
  CALL FUNCTION 'HR_IN_CHG_INR_WRDS'
    EXPORTING
      amt_in_num         = amt
    IMPORTING
      amt_in_words       = g_tot_text
    EXCEPTIONS
      data_type_mismatch = 1
      OTHERS             = 2.
  IF wa_vbrk-waerk = 'INR' .
    TRANSLATE g_tot_text TO UPPER CASE.
  ELSEIF wa_vbrk-waerk = 'USD'.
*  REPLACE  'RUPEES' IN G_TOT_TEXT WITH 'AND'.
*  REPLACE  'PAISE' IN G_TOT_TEXT WITH 'CENT'.
    REPLACE 'Rupees' WITH 'USD' INTO g_tot_text.
    REPLACE 'Paise' WITH 'Cent' INTO g_tot_text.
    REPLACE 'Paise' WITH 'Cent' INTO g_tot_text.
    TRANSLATE g_tot_text TO UPPER CASE.
  ENDIF.
ENDIF.
CLEAR acc_value .
LOOP AT  it_final INTO DATA(w_final1).
  acc_value = acc_value + w_final1-tot_amt .
ENDLOOP.
*break-point .
IF k007_valu IS NOT INITIAL .
  tot_acc_value = acc_value + k007_valu .
ELSE .
  tot_acc_value = acc_value .
ENDIF .
disc_txt = 'Discount'.
access_txt = 'Accessible value'.
igst_txt = 'IGST rate'.
cgst_txt = 'CGST rate'.
sgst_txt = 'SGST rate'.
tcs_txt = 'TCS rate'.
intrest_txt = 'Intrest rate'.
frieght_txt = 'Frieght rate'.
jtc1_txt = 'JTC1 rate'. " ADDED BY YUVRAJ 19.11.2020
jtc2_txt = 'JTC2 rate'. " ADDED BY YUVRAJ 19.11.2020
*BREAK-POINT .
*if igst_valu = '13.00'.
igst_value = '13'. "igst_valu .
*   igst_valu = ' '.
*endif .
CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
  EXPORTING
    p_object       = 'GRAPHICS'    " SAPscript Graphics Management: Application object
    p_name         = 'SANY_LOGO_WITH_SLOGAN1'    ": logo Name
    p_id           = 'BMAP'        "SAPscript Graphics Management: ID
    p_btype        = 'BCOL'        "SAPscript: Type of graphic
  RECEIVING
    p_bmp          = logo       "Graphic Data
  EXCEPTIONS
    not_found      = 1
    internal_error = 2
    OTHERS         = 3.
CONDENSE : wa_bill_to-name1 ,
           wa_bill_to-name2 ,
           wa_bill_to-street ,
           wa_bill_to-str_suppl2 ,
           wa_bill_to-str_suppl3 ,
           wa_bill_to-city1 ,
           wa_bill_to-post_code1 .
*append wa_bill to tt_bill .
wa_bill-text = wa_bill_to-name1 .
IF wa_bill_to-name1 IS INITIAL .
  wa_bill-ind = 'A'.
ENDIF .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
wa_bill-text = wa_bill_to-name2 .
IF wa_bill_to-name2 IS INITIAL .
  wa_bill-ind = 'A'.
ENDIF .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
wa_bill-text = wa_bill_to-street .
IF wa_bill_to-street IS INITIAL .
  wa_bill-ind  = 'A'.
ENDIF .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
wa_bill-text = wa_bill_to-str_suppl2 .
IF wa_bill_to-str_suppl2 IS INITIAL .
  wa_bill-ind  = 'A'.
ENDIF .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
wa_bill-text = wa_bill_to-str_suppl3.
IF wa_bill_to-str_suppl3 IS INITIAL .
  wa_bill-ind  = 'A'.
ENDIF .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
CONCATENATE wa_bill_to-city1 wa_bill_to-post_code1 INTO wa_bill-text  SEPARATED BY space  .
IF wa_bill-text IS INITIAL .
  wa_bill-ind  = 'A'.
ENDIF .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
*CONCATENATE 'Tel No :' wa_bill_to-tel_number INTO wa_bill-text SEPARATED BY space .
*APPEND wa_bill TO tt_bill .
*CLEAR wa_bill .    "Commented by TTL Tushar, On 02.07.2025 15:19:05
*
*CONCATENATE 'EMail:' wa_adr6-smtp_addr INTO wa_bill-text SEPARATED BY space  .
*APPEND wa_bill TO tt_bill .
*CLEAR wa_bill .     "Commented by TTL Tushar, On 02.07.2025 15:19:10
CONCATENATE 'GSTIN :' wa_kna1-stcd3 INTO wa_bill-text SEPARATED BY space .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
CONCATENATE 'PAN No :' waj_1imocust-j_1ipanno  INTO wa_bill-text  SEPARATED BY space .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
wa_bill-text = i_hypo .
APPEND wa_bill TO tt_bill .
CLEAR wa_bill .
DELETE tt_bill WHERE ind = 'A' .
LOOP AT tt_bill INTO wa_bill .
  CONCATENATE gv_bill cl_abap_char_utilities=>newline
            wa_bill-text INTO gv_bill.
  CONDENSE wa_bill-text  .
ENDLOOP .
SHIFT gv_bill LEFT BY 1 PLACES .
READ TABLE itj_1imocust INTO waj_1imocust WITH KEY kunnr = wa_vbrk-kunag.
CONDENSE : wa_ship_to-name1 ,
           wa_ship_to-name2 ,
           wa_ship_to-name_co ,               "added by Niranjan Shinde 14.12.2021
           wa_ship_to-street ,
           wa_ship_to-str_suppl1,              "added by Niranjan Shinde 07.12.2021
           wa_ship_to-str_suppl2 ,
           wa_ship_to-str_suppl3 ,
           wa_ship_to-location,                 "added by Niranjan Shinde 07.12.2021
           wa_ship_to-city1 ,
           wa_ship_to-post_code1 .
wa_ship-text = wa_ship_to-name1 .
IF wa_ship_to-name1 IS INITIAL .
  wa_ship-ind = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
wa_ship-text = wa_ship_to-name2 .
IF wa_ship_to-name2 IS INITIAL .
  wa_ship-ind = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*---------------------------added by Niranjan Shinde 14.12.2021--------------------------
wa_ship-text = wa_ship_to-name_co .
IF wa_ship_to-name_co IS INITIAL .
  wa_ship-ind  = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*-----------------------------------------------------------------------------------------
wa_ship-text = wa_ship_to-street .
IF wa_ship_to-street IS INITIAL .
  wa_ship-ind  = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*---------------------------added by Niranjan Shinde 07.12.2021--------------------------
wa_ship-text = wa_ship_to-str_suppl1 .
IF wa_ship_to-str_suppl1 IS INITIAL .
  wa_ship-ind  = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*-----------------------------------------------------------------------------------------
wa_ship-text = wa_ship_to-str_suppl2 .
IF wa_ship_to-str_suppl2 IS INITIAL .
  wa_ship-ind  = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
wa_ship-text = wa_ship_to-str_suppl3.
IF wa_ship_to-str_suppl3 IS INITIAL .
  wa_ship-ind  = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*---------------------------added by Niranjan Shinde 07.12.2021--------------------------
wa_ship-text = wa_ship_to-location .
IF wa_ship_to-location IS INITIAL .
  wa_ship-ind  = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*-----------------------------------------------------------------------------------------
CONCATENATE wa_ship_to-city1 wa_ship_to-post_code1 INTO wa_ship-text  SEPARATED BY space  .
IF wa_ship-text IS INITIAL .
  wa_ship-ind  = 'A'.
ENDIF .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*CONCATENATE 'Tel No :' wa_ship_to-tel_number INTO wa_ship-text SEPARATED BY space .
*APPEND wa_ship TO tt_ship .
*CLEAR wa_ship .    "Commented by TTL Tushar, On 02.07.2025 15:20:39
*
*CONCATENATE 'EMail:' wa_adr7-smtp_addr INTO wa_ship-text SEPARATED BY space  .
*APPEND wa_ship TO tt_ship .
*CLEAR wa_ship .    "Commented by TTL Tushar, On 02.07.2025 15:20:30
*---------ADDED BY DS-----------*
CONCATENATE 'GSTIN :' wa_kna2-stcd3 INTO wa_ship-text SEPARATED BY space .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
CONCATENATE 'PAN No :' waj_1imocust1-j_1ipanno  INTO wa_ship-text  SEPARATED BY space .
APPEND wa_ship TO tt_ship .
CLEAR wa_ship .
*--------------------------------*
DELETE tt_ship WHERE ind = 'A' .
BREAK abap4.
LOOP AT tt_ship INTO wa_ship .
  CONCATENATE gv_ship cl_abap_char_utilities=>newline
            wa_ship-text INTO gv_ship.
  CONDENSE wa_ship-text  .
ENDLOOP .
SHIFT gv_ship LEFT BY 1 PLACES .
CONDENSE : dp_name1 , dp_sup1 , dp_sup2 , dp_sup3 , dp_city1 , dp_post_code1 .
wa_dp-text = dp_name1 .
IF dp_name1 IS INITIAL .
  wa_dp-ind = 'A'.
ENDIF .
APPEND wa_dp TO tt_dp .
CLEAR wa_dp .
wa_dp-text = dp_sup1 .
IF dp_sup1 IS INITIAL .
  wa_dp-ind = 'A'.
ENDIF .
APPEND wa_dp TO tt_dp .
CLEAR wa_dp .
wa_dp-text =  dp_sup2 .
IF  dp_sup2  IS INITIAL .
  wa_dp-ind  = 'A'.
ENDIF .
APPEND wa_dp TO tt_dp .
CLEAR wa_dp .
wa_dp-text = dp_sup3 .
IF dp_sup3 IS INITIAL .
  wa_dp-ind  = 'A'.
ENDIF .
APPEND wa_dp TO tt_dp .
CLEAR wa_dp .
CONCATENATE dp_city1 dp_post_code1  INTO wa_dp-text  SEPARATED BY space  .
IF wa_dp-text IS INITIAL .
  wa_dp-ind  = 'A'.
ENDIF .
APPEND wa_dp TO tt_dp .
CLEAR wa_dp .
CONCATENATE 'GSTIN :' waj_1bbranch-gstin INTO wa_dp-text  SEPARATED BY space .
APPEND wa_dp TO tt_dp .
CLEAR wa_dp .
DELETE tt_dp WHERE ind = 'A' .
LOOP AT tt_dp INTO wa_dp .
  CONCATENATE gv_dp cl_abap_char_utilities=>newline
            wa_dp-text INTO gv_dp.
  CONDENSE wa_dp-text  .
ENDLOOP .
SHIFT gv_dp LEFT BY 1 PLACES .
IF i_vbeln IS NOT INITIAL.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = i_vbeln
    IMPORTING
      output = s_vbln.
  SELECT *
  FROM zeydigi_einv_azr
  INTO CORRESPONDING FIELDS OF TABLE gt_zeydigi_einv_azr
  FOR ALL ENTRIES IN it_vbrk
  WHERE documentnumber EQ s_vbln
    AND bukrs EQ it_vbrk-bukrs.
  SELECT SINGLE * FROM vbrk INTO wa_vbrk
    WHERE vbeln = i_vbeln.
  SELECT SINGLE * FROM vbrp INTO wa_vbrp
        WHERE vbeln = i_vbeln.
  SELECT SINGLE *
FROM kna1
INTO wa_kna1
WHERE kunnr = wa_vbrk-kunrg.
  SELECT SINGLE gstin FROM j_1bbranch
    INTO wa_qr-gstin
    WHERE bukrs = wa_vbrk-bukrs
    AND branch = wa_vbrp-werks.
ENDIF.
*  SELECT *
*  FROM ZEYDIGI_EINV_AZR
*  INTO CORRESPONDING FIELDS OF TABLE GT_ZEYDIGI_EINV_AZR
*  FOR ALL ENTRIES IN IT_VBRK
*  WHERE DOCUMENTNUMBER eq I_VBELN
*    and BUKRS eq IT_VBRK-BUKRS.
**    and FISCALYEAR eq IT_VBRK-GJAHR.
BREAK abap4.
wa_qr-documentnumber = i_vbeln.
wa_qr-documentdate = wa_vbrk-fkdat.
wa_qr-profitcentre1 = wa_vbrp-prctr.
wa_qr-invoicevalue = g_total.
wa_qr-invcgstamount = cgst_valu.
wa_qr-invsgstamount = sgst_valu.
wa_qr-invigstamount = igst_valu.
wa_qr-waers = 'INR'.
*WA_QR-GSTIN =
IF  ( wa_kna1-stcd3 = '' OR wa_kna1-stcd3 = 'NA' ) AND ( wa_vbrk-fkart = 'ZM76' OR wa_vbrk-fkart = 'ZM72' ).
  CALL FUNCTION 'ZAGST_GENERATE_B2C_QR_CODE'
    EXPORTING
      im_v_compcode = wa_vbrk-bukrs
      im_v_plant    = wa_vbrp-werks
      im_b2c_qr_inv = wa_qr
    IMPORTING
      ex_v_qrcode   = gv_signedqr
*   EXCEPTIONS
*     NO_QR_CODE    = 1
*     OTHERS        = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  TRY .
      cl_rstx_barcode_renderer=>qr_code(
    EXPORTING
      i_module_size      = 30
      i_mode             = 'A'
      i_error_correction = 'H'
      i_barcode_text     = gv_signedqr "GS_ZEYDIGI_EINV_AZR-SIGNED_QR
    IMPORTING
      e_bitmap           = gv_qcode
         ).
    CATCH cx_rstx_barcode_renderer.
  ENDTRY.
ELSE.
  LOOP AT gt_zeydigi_einv_azr INTO gs_zeydigi_einv_azr.
    IF gs_zeydigi_einv_azr-signed_qr IS NOT INITIAL.
      gv_qrcode2 = gs_zeydigi_einv_azr-signed_qr.
      lv_dynamic_len = strlen( gv_qrcode2 ).
      IF lv_dynamic_len GT 765.
        lv_len    = lv_dynamic_len - 765.
        gv_first  = gv_qrcode2(255).
        gv_second = gv_qrcode2+255(255).
        gv_third  = gv_qrcode2+510(255).
        gv_fourth = gv_qrcode2+765(lv_len).
      ENDIF.
      CLEAR gv_signedqr.
      CONCATENATE gv_first gv_second gv_third gv_fourth INTO gv_signedqr.
      TRY .
          cl_rstx_barcode_renderer=>qr_code(
        EXPORTING
          i_module_size      = 30
          i_mode             = 'A'
          i_error_correction = 'H'
          i_barcode_text     = gv_signedqr "GS_ZEYDIGI_EINV_AZR-SIGNED_QR
        IMPORTING
          e_bitmap           = gv_qcode
             ).
        CATCH cx_rstx_barcode_renderer.
      ENDTRY.
    ENDIF.
  ENDLOOP.
ENDIF.
*CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
*  EXPORTING
*    p_object       = 'GRAPHICS'    " SAPscript Graphics Management: Application object
*    p_name         = 'ZRA_LOGO'    ": logo Name
*    p_id           = 'BMAP'        "SAPscript Graphics Management: ID
*    p_btype        = 'BCOL'        "SAPscript: Type of graphic
*  RECEIVING
*    p_bmp          =  logo       "Graphic Data
*  EXCEPTIONS
*    not_found      = 1
*    internal_error = 2
*    others         = 3.
***   SOA for bugID SC3-I2006 on 22.04.2024 Tr no : SQSK904815
DATA : lv_parvw(2) TYPE c.
CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
  EXPORTING
    input  = 'BP'
  IMPORTING
    output = lv_parvw.
SELECT  vbeln , parvw ,kunnr
        FROM vbpa
        INTO TABLE @DATA(it_vbpa2)
        WHERE vbeln = @i_vbeln
        AND parvw = @lv_parvw.
READ TABLE it_vbpa2 INTO DATA(wa_vbpa2) WITH KEY vbeln = i_vbeln parvw = lv_parvw.
SELECT SINGLE kunnr, regio
       FROM kna1
       INTO @DATA(wa_kna3)
       WHERE kunnr = @wa_vbpa2-kunnr.
SELECT SINGLE bland ,bezei
  FROM t005u
  INTO @DATA(wa_t005u1)
  WHERE spras = @sy-langu AND
        land1 = 'IN' AND
        bland = @wa_kna3-regio.
lv_bezei = wa_t005u1-bezei.
***   EOA for bugID SC3-I2006 on 22.04.2024 Tr no : SQSK904815