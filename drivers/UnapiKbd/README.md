# UNAPI DRIVER
Below the specification of an UNAPI compliant HID keyboard API.

## API Information Routine

Input: A = 0

Output:
* HL = Address of the implementation name string
* DE = API specification version supported. D=primary, E=secondary.
* BC = API implementation version. B=primary, C=secondary.

## Check

Input: A = 1

Check if the USB UNAPI driver is present, a USB HID device plus Keyboard is connected.

## Hook

Input: A = 2

Hook the USB HID keyboard. You can now start typing on the USB HID Keyboard. The built-in MSX keyboard is disabled.
The driver will unhook when ALT+Q is pressed. Or when the Unhook command is given.

## Unhook

Input: A = 3

Unhook the USB HID keyboard. You can now type again on the built-in MSX keyboard.