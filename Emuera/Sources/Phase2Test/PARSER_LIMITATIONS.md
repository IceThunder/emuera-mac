# Parser Limitations - Known Issues

This document tracks known parser limitations compared to C# Emuera.

## TINPUT/TINPUTS/TONEINPUT/TONEINPUTS

**C# Emuera Syntax:**
```
TINPUT timeout, default, display_time, timeout_message
TINPUTS timeout, default_string, display_time, timeout_message
```

**Current Parser Support:**
```
TINPUT timeout  // Only 1 argument supported
TINPUTS timeout // Only 1 argument supported
```

**Issue:** `parseInputCommand()` uses `parseSpaceSeparatedArguments(exactCount: 1)`

**Fix:** Update to support 2-4 arguments with defaults

---

## SET Command

**C# Emuera Syntax:**
```
SET A = 10
```

**Current Parser Support:**
```
A = 10  // ExpressionStatement, not SET command
```

**Issue:** SET is not in Command enum, handled as ExpressionStatement

**Fix:** Add SET to Command enum or document as alternative syntax

---

## SETCOLOR/SETBGCOLOR

**C# Emuera Syntax:**
```
SETCOLOR 255, 255, 255  // RGB values
SETCOLOR 0xFFFFFF       // Single color value
```

**Current Parser Support:**
```
SETCOLOR 0xFFFFFF  // Only 1 argument supported
```

**Issue:** `parseColorCommand()` uses `parseSpaceSeparatedArguments(exactCount: 1)`

**Fix:** Update to support 1 or 3 arguments

---

## DO-LOOP with Assignments

**C# Emuera Syntax:**
```
DO
    A = A + 1
LOOP WHILE A < 5
```

**Current Parser Support:**
```
DO
    A = A + 1  // Should work but test shows error
LOOP WHILE A < 5
```

**Issue:** Parser should support this, but test shows "unexpectedToken(operator(=))"

**Investigation:** Need to verify if this is a test issue or parser bug

---

## Test Results

**Current Status:** 289/299 commands verified (96.7% success rate)

**Failing Tests (10):**
1. TINPUT - needs 2-4 args, parser supports 1
2. TINPUTS - needs 2-4 args, parser supports 1
3. TONEINPUT - needs 2-4 args, parser supports 1
4. TONEINPUTS - needs 2-4 args, parser supports 1
5. SET - uses ExpressionStatement syntax instead
6. SETCOLOR - needs 1 or 3 args, parser supports 1
7. SETBGCOLOR - needs 1 or 3 args, parser supports 1
8. DO-LOOP WHILE - parser issue with assignments
9. DO-LOOP UNTIL - parser issue with assignments

**All other 289 commands work correctly!**
