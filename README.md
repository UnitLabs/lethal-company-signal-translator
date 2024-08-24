# Lethal Company's Signal Translator for Garry's Mod

Just a funny thing I wanted to make. Use `transmit MESSAGE` to send a message to everyone.

Example: `transmit HELLO`

# CLIENT ConVars

`cl_signaltranslator_enabled 0-1` \
Enables Signal Translator. \
**Default:** `1`

`cl_signaltranslator_sound 0-1` \
Enables Signal Translator's sound. \
**Default:** `1`

`cl_signaltranslator_soundvol 0-1` \
Signal Translator's sound volume. \
**Default:** `0.6`

`cl_signaltranslator_additive 0-1` \
Makes font to be additive. \
**Default:** `1`

# SERVER ConVars

`sv_signaltranslator_enabled 0-1` \
Enables Signal Translator's command `transmit`. \
**Default:** `1`

`sv_signaltranslator_maxlen 1-24` \
Signal Translator max length for `transmit`. \
**Default:** `9`

`sv_signaltranslator_adminonly 0-1` \
Restrict `transmit` only for admins. \
**Default:** `1`

# Lua API

```lua
--- Transmits message to clients.
---
--- @param message string
--- @param owner player|nil
---
--- @return boolean ok, string error-msg
---
--- @server
SignalTranslator(message, owner)

--- This hook is called before sending the message to the clients. Return `false` to
--- disallow.
---
--- @param message string
--- @param owner player|nil
---
--- @return boolean allow
---
--- @shared
GM:PreSignalTranslator(message, owner)

--- This hook is called after sending the message to the clients.
---
--- @param message string
--- @param owner player|nil
---
--- @shared
GM:OnSignalTranslator(message, owner)
```