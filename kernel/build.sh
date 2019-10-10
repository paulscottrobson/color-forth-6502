
python scripts/combuffer.py >testing/buffer.inc
python scripts/genconst.py >generated/constants.voc
python scripts/createdictionary.py >generated/dictionary.inc

64tass -q -c main.asm -o cforth.prg -L cforth.lst
if [ $? -eq 0 ]; then
	../../x16-emulator/x16emu -prg cforth.prg -run -debug -scale 2
fi