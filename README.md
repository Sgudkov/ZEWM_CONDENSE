# ZEWM_CONDENSE
 This example allow you to condense storage bin after confirm WT process.
 
 If your storage bin doesn't allow you to accept a goods in several separated HU,
 you can use this example to condense recieving goods in destination bin without nesting HU.
 
 For avoid nesting you have to: 
 1. Create FM with example [source code](https://github.com/Sgudkov/ZEWM_CONDENSE/blob/main/ZEWM_CONDESE.abap)
 2. Implement BADI /SCWM/EX_CORE_CO_POST.
 3. In method POST create RFQ queue using FM TRFC_SET_QIN_PROPERTIES.
 4. Call created FM with parametrs "IN BACKGROUND TASK AS SEPARATE UNIT".
 5. Please don't forget to register your queue name in SMQE.

 