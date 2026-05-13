* Paste this block into SMARTFORMS -> Global Definitions -> Types tab
* Source: Adobe Form ZSANY_INVOICE_INTERFACE

*types: IT_VBRK  TYPE TABLE OF VBRK,
*  IT_VBRP  TYPE TABLE OF VBRP,
*       IT_VBAP  TYPE TABLE OF VBAP,
*       IT_VBAK  TYPE TABLE OF VBAK,
*       IT_LIKP  TYPE TABLE OF LIKP,
*       IT_KONV  TYPE TABLE OF KONV,
*       ITJ_1IMOCUST  TYPE TABLE OF J_1IMOCUST,
*       IT_OBJK  TYPE TABLE OF OBJK,
*       IT_EKKO  TYPE TABLE OF EKKO,
*       IT_EKPO  TYPE TABLE OF EKPO,
*       IT_VBPA  TYPE TABLE OF VBPA,
*       IT_VBPA1  TYPE TABLE OF VBPA,
*       ITJ_1IMOCUST1  TYPE TABLE OF J_1IMOCUST,
*       LT_VBPA  TYPE TABLE OF VBPA.
***********
*types : begin of vbrk_1,
*  vkorg type vbrk-vkorg,
*  vtweg type vbrk-vtweg,
*  kunrg type vbrk-kunrg,
*end of vbrk_1.
types : it_vbrk_1 type TABLE OF vbrk.
TYPES : BEGIN OF TY_BILL ,
     NAME1 TYPE ADRC-NAME1 ,
     NAME2 TYPE ADRC-NAME2 ,
     NAME_CO TYPE ADRC-NAME_CO,                        "added by Niranjan Shinde 14.12.2021.
       STREET TYPE ADRC-STREET ,
       STR_SUPPL2 TYPE ADRC-STR_SUPPL2 ,
       STR_SUPPL3 TYPE ADRC-STR_SUPPL3 ,
       CITY1 TYPE ADRC-CITY1 ,
       POST_CODE1 TYPE ADRC-POST_CODE1 ,
       TEL_NUMBER  TYPE ADRC-TEL_NUMBER ,
       STR_SUPPL1  TYPE ADRC-STR_SUPPL1,
       LOCATION  TYPE ADRC-LOCATION,                    "added by Niranjan Shinde 07.12.2021
      END OF TY_BILL .
types : tt_bill1 TYPE TABLE OF ty_bill .
types: TT_VBRK  TYPE TABLE OF VBRK,
       TT_VBRP  TYPE TABLE OF VBRP,
       TT_VBAP  TYPE TABLE OF VBAP,
       TT_VBAK  TYPE TABLE OF VBAK,
       TT_LIKP  TYPE TABLE OF LIKP,
       TT_KONV  TYPE TABLE OF KONV,
       TTJ_1IMOCUST  TYPE TABLE OF J_1IMOCUST,
       TT_OBJK  TYPE TABLE OF OBJK,
       TT_EKKO  TYPE TABLE OF EKKO,
       TT_EKPO  TYPE TABLE OF EKPO,
       TT_VBPA  TYPE TABLE OF VBPA.
types : begin of ty_text ,
        text type string ,
        ind  type c ,
        end of ty_text .
types :tt_text TYPE TABLE OF ty_text .
TYPES : begin of ST_FINAL,
       C_SR_NO TYPE STRING ,
       SR_NO TYPE I,
       SERIAL TYPE STRING ,
       matnr TYPE vbrp-matnr,
       arktx TYPE vbrp-arktx,
       I_SERNR TYPE string,
       DESC TYPE  string,
       descp(1000) type c ,                   "*****&wa_vbrp-matnr& / &wa_vbrp-arktx(C)& &I_SERNR(C)&
       VCBC TYPE STRING,                       "*******VCBC               : &I_VCBC(C)&                     CONDITION I_FKART = 'ZM72'     I_VCBC NE ' '
       VCBC_DESC TYPE STRING,                 "********VCBC Description   : &I_VCBC_DESC(C)&              CONDITION I_FKART = 'ZM72'     I_VCBC_DESC NE ' '
       I_CHALLAN_NO TYPE STRING,              "********Challan No.        : &I_CHALLAN_NO&         CONDITION I_FKART = 'ZM72'      I_CHALLAN_NO NE ' '
       I_CHALLAN_DATE TYPE STRING,            "********Challan Date       : &I_CHALLAN_DATE(C)&   CONDITION I_FKART = 'ZM72'      I_CHALLAN_DATE NE ' '
       I_BODY_SERNO TYPE STRING,               "********Body Serial No.    : &I_BODY_SERNO(C)&                CONDITION I_FKART = 'ZM72'      I_CHALLAN_DATE NE ' '
       I_CHASIS_NO TYPE STRING,                "*********Chassis No.        : &I_CHASSIS_NO(C)&               CONDITION I_FKART = 'ZM72'      I_CHASSIS_NO NE ' '
       I_ENGINE_NO TYPE STRING,               "*********Engine No.         : &I_ENGINE_NO(C)&                CONDITION I_FKART = 'ZM72'      I_ENGINE_NO NE ' '
       HSC_CODE TYPE MARC-STEUC,              "*******hsn_sac
       quantity type vbrp-FKLMG,              "*******wa_vbrp-FKLMG(C)
       unit type vbrp-meins,                  "****&wa_vbrp-meins(C)&
       rate TYPE P DECIMALS 2,                          "***&rate(C)&
       tot_amt type P DECIMALS 2,          "******&total(C)&
       kdmat type knmt-kdmat,
     END OF ST_FINAL.
types : TT_FINAL TYPE TABLE OF ST_FINAL.