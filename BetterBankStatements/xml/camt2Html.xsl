<?xml version="1.0" encoding="UTF-8"?>

<!-- made from https://github.com/dpocock/camt053-xsl -->

<!-- Note:
       It is necessary to tweak the camt 053 namespace version in
       the xmlns:camt definition below to match the exact version used
       in the input document, e.g. for Postfinance Switzerland, you
       may need to use
         xmlns:camt="urn:iso:std:iso:20022:tech:xsd:camt.053.001.02"
       and for the ISO 20022 sample document use
         xmlns:camt="urn:iso:std:iso:20022:tech:xsd:camt.053.001.04"
  -->

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:camt="urn:iso:std:iso:20022:tech:xsd:camt.053.001.02"
                xmlns:saxon="http://saxon.sf.net/">
  <xsl:output method="html" indent="yes" encoding="UTF-8"/>
<xsl:decimal-format name="slodec" decimal-separator="," grouping-separator="."/>



  <!-- Look at the file's GrpHdr -->
  <xsl:template match="/camt:Document/camt:BkToCstmrStmt/camt:GrpHdr">
    <!-- Check if the camt 053 statement is contained within a single file/message
         We don't handle statements split into multiple files yet
         and if one is encountered, the translation will be aborted -->
    <xsl:if test="camt:MsgPgntn/camt:PgNb != 1 or camt:MsgPgntn/camt:LastPgInd != 'true'">
      <xsl:message terminate="yes">
        <xsl:text>Incomplete message (not first page or subsequent pages exist)</xsl:text>
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <!-- Handle one of the summary rows (opening or closing balance details) -->
  <xsl:template match="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Bal">
    <td>
      <xsl:choose>
        <xsl:when test="camt:Tp/camt:CdOrPrtry/camt:Cd = 'OPBD'">Predhodnje stanje: </xsl:when>
        <xsl:when test="camt:Tp/camt:CdOrPrtry/camt:Cd = 'CLBD'">Novo stanje: </xsl:when>
        <xsl:otherwise>-</xsl:otherwise>
      </xsl:choose>
    </td>
    <td class="aright">
      <xsl:if test="camt:CdtDbtInd != 'CRDT'">-</xsl:if>
      <b>
        <xsl:value-of select="format-number(camt:Amt, '#.##0,00', 'slodec')"/>
      </b>
    </td>
  </xsl:template>

  <!-- Handle one of the entries in the list of transactions -->
  <xsl:template match="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Ntry">
    <tr>
      <td>
        <xsl:value-of select="format-date(camt:BookgDt/camt:Dt,'[D00].[M00].[Y]')"/>
      </td>
      <td>

        <div>
          <xsl:value-of select="camt:NtryDtls/camt:TxDtls/camt:RltdPties/camt:*/camt:Nm"/>
        </div>
        <div>
          <xsl:value-of select="camt:AddtlNtryInf"/>
        </div>
      </td>
      <td>
        <xsl:value-of select="camt:NtryDtls/camt:TxDtls/camt:RmtInf/camt:Strd/camt:CdtrRefInf/camt:Ref"/>
        <br/>
        <xsl:value-of select="camt:NtryDtls/camt:TxDtls/camt:RmtInf/camt:Strd/camt:AddtlRmtInf"/>
      </td>

      <td class="aright">
        <xsl:if test="camt:CdtDbtInd = 'CRDT'">
          <xsl:value-of select="format-number(camt:Amt, '#.##0,00', 'slodec')"/>
        </xsl:if>
      </td>
      <td class="aright">
        <xsl:if test="camt:CdtDbtInd = 'DBIT'">
          <xsl:value-of select="format-number(camt:Amt, '#.##0,00', 'slodec')"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Handle the root node of the XML document -->
  <xsl:template match="/">
    <HTML>
      <head>
        <style>
          *{font-family: Tahoma, Geneva, sans-serif; font-size: 12px;}
          table.myTable {border-collapse: collapse; font-size: 10px; width:100%;
          }
          table.myTable td, table.myTable th {
          border: 1px solid #AAAAAA;
          }
          table.myTable thead {
          background: #D0E4F5; text-align:left;
          }
          table.myTable thead th {
          font-weight: normal;
          }
          .aright {text-align: right;}

          table.myTable tr:nth-child(even) {
          background: #F6F6F6;
-webkit-print-color-adjust: exact;
  color-adjust: exact;
          }
          .naslov {text-align: center; font-size: 14px; font-weight: bold;}

@media print {
    .nerezi {
    page-break-inside:avoid;
    }
}
        </style>
      </head>
      <body>
        <xsl:for-each select="collection('.?recurse=no;select=*.xml')" xmlns:saxon="http://saxon.sf.net/">
<div class="nerezi">          
<p class="naslov">
            Izpis prometa in stanje na računu <br/> <xsl:value-of select="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Acct/camt:Id"/> (<xsl:value-of select="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Acct/camt:Ownr/camt:Nm"/>) na dan
            <xsl:value-of select="format-dateTime(/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:CreDtTm,'[D00].[M00].[Y]')"/>


            <!-- Check the GrpHdr first -->
            <xsl:apply-templates select="./camt:Document/camt:BkToCstmrStmt/camt:GrpHdr"/>

            <!-- Start generating an html document -->


            <!-- Header for every page -->
<br/>            
<div font-size="9pt" font-family="sans-serif">
              Št. izpiska: <b>
                <xsl:value-of select="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:LglSeqNb"/>
              </b>
              &#160;&#160;&#160;&#160;&#160;Datum izpiska: <b>
                <xsl:value-of select="format-dateTime(/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:CreDtTm,'[D00].[M00].[Y]')"/>
              </b>

            </div>

<br/>

            <!-- List of transaction details -->
            <br/>

            <xsl:choose>
              <xsl:when test="count(/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Ntry) = 0">
                <div font-style="italic" text-align="center">No entries booked in this period</div>
              </xsl:when>
              <xsl:otherwise>
                <table class="myTable">
                  <thead>
                    <tr>
                      <th>
                        <div style="padding-top:5px;padding-bottom: 5px;">Datum</div>
                      </th>
                      <th>
                        Plačnik/Prejemnik
                      </th>
                      <th>
                        Sklic
                      </th>

                      <th class="aright">
                        Priliv
                      </th>
                      <th class="aright">
                        Odliv
                      </th>
                    </tr>
                  </thead>

                  <tbody>
                    <xsl:apply-templates select="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Ntry"/>
                  </tbody>

                </table>
              </xsl:otherwise>
            </xsl:choose>
<br/>
            <xsl:variable name="sumDBIT" select="sum(/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Ntry[camt:CdtDbtInd='DBIT']/camt:Amt)"/>
            <xsl:variable name="sumCRDT" select="sum(/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Ntry[camt:CdtDbtInd='CRDT']/camt:Amt)"/>

            <table>
              <tr>
                <xsl:apply-templates select="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Bal/camt:Tp/camt:CdOrPrtry/camt:Cd[text()='OPBD']/../../.."/>
              </tr>
              <tr>
                <td>Promet v breme:</td>
                <td class="aright">
                  -<xsl:copy-of select="format-number($sumDBIT, '#.##0,00', 'slodec')" />
                </td>
              </tr>
              <tr>
                <td>Promet v dobro:</td>
                <td class="aright">
                  <xsl:copy-of select="format-number($sumCRDT, '#.##0,00', 'slodec')" />
                </td>
              </tr>
              <tr>
                <xsl:apply-templates select="/camt:Document/camt:BkToCstmrStmt/camt:Stmt/camt:Bal/camt:Tp/camt:CdOrPrtry/camt:Cd[text()='CLBD']/../../.."/>
              </tr>
            </table>
            
          </p>
</div>
        </xsl:for-each>
      </body>
    </HTML>
  </xsl:template>

</xsl:stylesheet>
