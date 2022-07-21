
package;
import cpp.ConstCharStar;

//#if cpp
//macro de mierda ni hace falta
@:headerCode('#include "windows.h"')

class Elpepe {
	//Parametros de windows:p
	@:functionCode('SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PVOID(p), SPIF_UPDATEINIFILE);')
	public static function systemParametersInfo(p:ConstCharStar):Bool {
		return true;
		trace("funciona la concha de tu madre");
	}

	public static function cambiarFondo(ruta:String)
		{
			Elpepe.systemParametersInfo(ruta);
		}
}
//#end

