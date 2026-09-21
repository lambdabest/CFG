# Counter-Strike 1.6 — Cliente competitivo 240 Hz

Configuración personal para **Counter-Strike 1.6 Steam (steam_legacy)** orientada a LAN 5v5, 240 Hz, Raw Input y una instalación lo más limpia posible.

## Opciones de lanzamiento

```text
-freq 240 -noforcemparms -console -nojoy +exec 1.cfg -stretchaspect
```

No se usan `-noforcemaccel` ni `-noforcemspd` porque `-noforcemparms` ya conserva los tres parámetros de mouse de Windows en el código de Valve.

## Instalación

Copia el contenido de `CFG/` dentro de:

```text
Steam\steamapps\common\Half-Life\cstrike\
```

La carga queda así:

```text
+exec 1.cfg
  -> competitive_240hz.cfg
  -> userconfig.cfg
```

## Perfil técnico

```cfg
fps_override "1"
fps_max "240"
gl_vsync "0"

rate "100000"
cl_updaterate "102"
cl_cmdrate "245"
cl_cmdbackup "0"
ex_interp "0.01"

cl_lc "1"
cl_lw "1"

m_rawinput "1"
m_filter "0"
m_customaccel "0"
```

### Sobre cl_cmdrate 245

`245` sigue la regla de esta LAN: **fps_max + 5**. No es una regla oficial de GoldSrc; es una política del entorno competitivo.

### Sobre cl_updaterate

Se usa `102`. Escribir decimales como `102.000003814697...` no entrega una tasa superior: el valor efectivo mostrado por el motor sigue siendo 102.

### Sobre ex_interp

Se usa `0.01`. Con updaterate 102, el intervalo matemático entre actualizaciones es ~9.804 ms. El comportamiento exacto de `ex_interp 0` sigue siendo objeto de discusión en el tracker de Valve, por lo que este perfil usa 10 ms de forma explícita y estable.

## Mouse — sin aceleración

El perfil fuerza:

```cfg
m_rawinput "1"
m_filter "0"
m_customaccel "0"
m_mousethread_sleep "10"
```

Con Raw Input, el código actual de Valve obtiene el movimiento mediante SDL relative mouse state. Por eso **MarkC no es necesario para el apuntado dentro de CS 1.6 cuando `m_rawinput 1` está funcionando**.

Recomendación de Windows:
- Enhance pointer precision: **OFF**
- No usar `-mousethread`
- MarkC: opcional para comportamiento del puntero fuera de la ruta Raw Input; no forma parte obligatoria de este repositorio.

## LAN confiable vs servidores públicos

El perfil competitivo usa:

```cfg
cl_filterstuffcmd "0"
```

porque el servidor LAN administrado puede necesitar aplicar/normalizar rates.

Antes de conectarte a servidores públicos ejecuta:

```text
exec public_safe.cfg
```

que restaura:

```cfg
cl_filterstuffcmd "1"
```

## Verificación

En consola:

```text
exec verify_client.cfg
```

Revisa FPS, rates, interp, predicción, smoothing, mouse y VSync.

## Archivos retirados

Este repositorio ya no incluye:
- `default_torneo.cfg` con CVARs antiguos/de servidor;
- tweaks TCP vendidos como “Low Ping Mode”;
- scripts de reinicio de adaptador como supuesto tweak competitivo;
- CRU empaquetado;
- ejecutables de polling/latency de terceros;
- BAT para bloquear `custom.hpk` / `tempdecal.wad`;
- MouseFix personalizado `@3-of-11`.

Esas herramientas no forman parte del perfil de input lag/hit registration y mezclarlas con el CFG dificultaba saber qué estaba realmente activo.

## Privacidad

No guardes `setinfo _pw`, RCON, contraseñas ni otros secretos en este repositorio público.

## Referencias

- Valve mouse/input code: https://github.com/ValveSoftware/halflife/blob/master/cl_dll/inputw32.cpp
- Valve netcode discussion: https://github.com/ValveSoftware/halflife/issues/3109
- Valve competitive defaults proposal: https://github.com/ValveSoftware/halflife/issues/3341
- ReHLDS shot-event issue: https://github.com/rehlds/ReHLDS/issues/1167
