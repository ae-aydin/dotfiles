#!/bin/bash
# Calculator (SUPER+C): type an expression in fuzzel, the result shows above the prompt and is
# copied to the clipboard; keep typing for the next one, Esc closes. ^ = power, math functions work (sqrt, sin, pi).
calc() {
    python3 -I -c '
import math, sys
expr = sys.argv[1].replace("^", "**")
try:
    r = eval(expr, {"__builtins__": {}}, {k: getattr(math, k) for k in dir(math) if not k.startswith("_")} | {"abs": abs, "round": round})
except Exception:
    sys.exit(1)
if isinstance(r, float) and r.is_integer() and abs(r) < 1e15:
    r = int(r)
print(f"{r:.12g}" if isinstance(r, float) else r)
' "$1"
}

mesg="e.g. 12*7.5, 2^10, sqrt(2)"
while expr=$(fuzzel --dmenu --prompt-only="calc > " --mesg="$mesg" --width=40) && [[ -n $expr ]]; do
    if result=$(calc "$expr"); then
        wl-copy "$result"
        mesg="$expr = $result   (copied)"
    else
        mesg="can't calculate: $expr"
    fi
done
