/*
ZE_GRAFTEMPO - GRAFICOS DE PROCESSAMENTO
1990.05 - Jos� Quintas
*/

#include "inkey.ch"
#include "set.ch"

#define GRAFMODE 1
#define GRAFTIME 2

FUNCTION GrafProc( nRow, nCol )

   THREAD STATIC GrafInfo := { 1, "X" }
   LOCAL mSetDevice

   hb_Default( @nRow, MaxRow() - 1 )
   hb_Default( @nCol, MaxCol() - 2 )
   IF GrafInfo[ GRAFTIME ] != Time()
      mSetDevice := Set( _SET_DEVICE, "SCREEN" )
      @ nRow, nCol SAY "(" + Substr( "|/-\", GrafInfo[ GRAFMODE ], 1 ) + ")" COLOR SetColorMensagem()
      GrafInfo[ GRAFMODE ] = iif( GrafInfo[ GRAFMODE ] == 4, 1, GrafInfo[ GRAFMODE ] + 1 )
      Set( _SET_DEVICE, mSetDevice )
      GrafInfo[ GRAFTIME ] := Time()
   ENDIF

   RETURN .T.

FUNCTION GrafTempo( xContNow, xContTotal )

   THREAD STATIC nStaticSecondsOld := 0, nStaticSecondsIni := 0, cStaticTxtBar := "", cStaticTxtText := ""
   LOCAL nSecondsNow, nSecondsRemaining, nSecondsElapsed, nCont, nPos, cTxt, cCorAnt
   LOCAL nPercent, cTexto, mSetDevice

   IF Empty( cStaticTxtBar )
      cStaticTxtBar := Replicate( ".", MaxCol() )
      FOR nCont = 1 to 10
         nPos          := Int( Len( cStaticTxtBar ) / 10 * nCont )
         cTxt          := lTrim( Str( nCont, 3 ) ) + "0%" + Chr(30)
         cStaticTxtBar := Stuff( cStaticTxtBar, ( nPos - Len( cTxt ) ) + 1, Len( cTxt ), cTxt )
      NEXT
      cStaticTxtBar := Chr(30) + cStaticTxtBar
   ENDIF
   mSetDevice := Set( _SET_DEVICE, "SCREEN" )
   DO CASE
   CASE ValType( xContNow ) == "C" .OR. xContNow == NIL
      cTexto            := xContNow
      nStaticSecondsIni := Int( Seconds() )
   CASE xContTotal == NIL
      nPercent := xContNow
   CASE xContNow >= xContTotal
      nPercent := 100
   OTHERWISE
      nPercent := xContNow / xContTotal * 100
   ENDCASE
   xContNow   := iif( ValType( xContNow ) != "N", 0, xContNow )
   xContTotal := iif( ValType( xContTotal ) != "N", 0, xContTotal )

   cCorAnt := SetColor()
   SetColor( SetColorMensagem() )
   nSecondsNow := Int( Seconds() )
   IF nPercent == NIL
      nStaticSecondsOld := nSecondsNow
      Mensagem()
      @ MaxRow(), 0 SAY cStaticTxtBar
      cStaticTxtText := iif( cTexto == NIL, "", cTexto )

   ELSEIF nPercent == 100 .OR. ( nSecondsNow != nStaticSecondsOld .AND. nPercent != 0 )
      nStaticSecondsOld := nSecondsNow
      nSecondsElapsed   := nSecondsNow - nStaticSecondsIni
      DO WHILE nSecondsElapsed < 0
         nSecondsElapsed += ( 24 * 3600 ) // Acima de 24 horas
      ENDDO
      nSecondsRemaining := nSecondsElapsed / nPercent * ( 100 - nPercent )
      @ MaxRow()-1, 0 SAY cStaticTxtText + " " + Ltrim( Transform( xContNow, PicVal(14,0) ) ) + "/" + Ltrim( Transform( xContTotal, PicVal(14,0) ) )
      cTxt := "Gasto:"
      cTxt += " " + Ltrim( Str( Int( nSecondsElapsed / 3600 ), 10 ) ) + "h"
      cTxt += " " + Ltrim( Str( Mod( Int( nSecondsElapsed / 60 ), 60 ), 10, 0 ) ) + "m"
      cTxt += " " + Ltrim( Str( Mod( nSecondsElapsed, 60 ), 10, 0 ) ) + "s"
      cTxt += Space(3)
      cTxt += "Falta:"
      cTxt += " " + Ltrim( Str( Int( nSecondsRemaining / 3600 ), 10 ) ) + "h"
      cTxt += " " + Ltrim( Str( Mod( Int( nSecondsRemaining / 60 ), 60 ), 10, 0 ) ) + "m"
      cTxt += " " + Ltrim( Str( Mod( nSecondsRemaining, 60 ), 10, 0 ) ) + "s"
      @ Row(), Col() SAY Padl( cTxt, MaxCol() - Col() - 4 )
      GrafProc()
      @ MaxRow(), 0 SAY Left( cStaticTxtBar, Len( cStaticTxtBar ) * nPercent / 100 ) COLOR SetColorFocus()
   ENDIF
   SetColor( cCorAnt )
   SET( _SET_DEVICE, mSetDevice )

   RETURN .T.
