# 🔧 ה-DESIGN - הסבר פשוט

## 🎯 מה הדיזיין?

ה-**Design** שלנו הוא **CRC Calculator** - משהו שמחשב Cyclic Redundancy Check.

```
INPUT:
  ├─ 32-bit data: 0xDEADBEEF
  └─ 8-bit polynomial: 0x1D

DUT (crc_dut.sv):
  ├─ State Machine
  ├─ Function: calculate_crc()
  └─ XOR operations

OUTPUT:
  ├─ 8-bit CRC result
  └─ Status signals
```

---

## 🏠 ה-Testbench (Crc_tb_top.sv)

**זה ה-"בית" של כל משהו.**

```
┌─────────────────────────────────────┐
│   crc_tb_top Module                 │
│  (כל הסביבה בפנים!)                 │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │   Clock      │  │   Reset     │ │
│  │  (100 MHz)   │  │  (20ns)     │ │
│  └──────────────┘  └─────────────┘ │
│           │              │          │
│           └──────┬───────┘          │
│                  │                  │
│          ┌───────▼────────┐        │
│          │   crc_if       │        │
│          │ (ממשק/אותות)    │        │
│          └───────┬────────┘        │
│                  │                  │
│          ┌───────▼────────┐        │
│          │    crc_dut     │        │
│          │  (ה-Design)     │        │
│          └────────────────┘        │
│                                     │
│          ┌──────────────────────┐  │
│          │  UVM Test (src/)     │  │
│          │  ├─ Driver           │  │
│          │  ├─ Monitor          │  │
│          │  ├─ Predictor        │  │
│          │  └─ Scoreboard       │  │
│          └──────────────────────┘  │
└─────────────────────────────────────┘
```

### חלקי ה-Testbench:

1. **Clock**: מבדיל הזמן לכל כן (100MHz = כל 10ns)
2. **Reset**: משחרר את ה-DUT להתחיל (אחרי 20ns)
3. **Interface (crc_if)**: ה-"חוט" בין הטסטבנץ' וה-DUT
4. **DUT (crc_dut)**: ה-DESIGN שבדקים
5. **UVM Test**: מה לעשות ומה לבדוק

---

## 🔴 ה-DUT - מה הוא (crc_dut.sv)?

זה מודול שמחשב **CRC - Cyclic Redundancy Check**.

### ממשק ה-DUT:

```
INPUT PINS:
├─ clk              - שעון
├─ rst_n            - reset (אקטיבי-נמוך)
├─ valid            - "יש נתונים"
├─ enable           - "בדוק!"
├─ data_in[31:0]    - 32 bit של נתונים
└─ polynomial[7:0]  - ה-חוק XOR

OUTPUT PINS:
├─ ready            - "מוכן לנתון הבא"
├─ busy             - "עדיין עובד"
├─ crc_out[7:0]     - התוצאה (8 bit)
├─ error            - "יש שגיאה"
└─ done             - "סיימתי"
```

### מה הוא עושה?

```
שלב 1: מחכה בIDLE
   ready = 1, busy = 0

שלב 2: קולט valid=1 ו-enable=1
   - מחשב CRC
   - state → PROCESS
   - busy = 1, ready = 0

שלב 3: עובד
   - לוקח כל 32 ביט
   - עושה XOR עם polynomial
   - קונספנט בפי 32

שלב 4: סיים
   - state → DONE
   - שולח את התוצאה ב-crc_out
   - שולח done = 1

שלב 5: חוזר לIDLE
   - מוכן לעסקה הבאה
```

---

## 🧮 איך הוא מחשב CRC?

```systemverilog
function logic [7:0] calculate_crc(logic [31:0] data, logic [7:0] poly);
    logic [7:0] crc = 8'hFF;  // התחלה = 0xFF
    int i;
    
    // לכל אחד מ-32 הביטים של הנתונים:
    for (i = 0; i < 32; i++) begin
        // 1. קח את הביט הגבוה של ה-CRC
        logic msb = crc[7];
        
        // 2. הזז שמאלה
        crc = crc << 1;
        
        // 3. הכנס ביט מהנתונים
        crc[0] = data[31-i];
        
        // 4. אם היה MSB=1, עשה XOR עם polynomial
        if (msb) crc = crc ^ poly;
    end
    
    return crc;  // התוצאה!
endfunction
```

**דוגמה:**
```
data = 0xDEADBEEF
poly = 0x1D

Iteration 0: crc = FF, msb = 1, shift, XOR
Iteration 1: crc = next, msb = ?, shift, XOR?
...
Iteration 31: crc = last

RESULT: crc_out = 0x?? (כלשהו 8-bit ערך)
```

---

## 📊 State Machine ה-DUT

```
┌──────────────────────────────────┐
│         DUT State Machine        │
└──────────────────────────────────┘

              START
               │
               ▼
      ┌───────────────┐
      │    IDLE       │
      │  state = 00   │
      │               │
      │ Wait for:     │
      │ valid=1 AND   │
      │ enable=1      │
      └───┬───────────┘
          │ (Got signal)
          ▼
      ┌───────────────┐
      │   PROCESS     │
      │  state = 01   │
      │               │
      │ Do work:      │
      │ calculate_crc │
      │ Set result    │
      └───┬───────────┘
          │ (Next cycle)
          ▼
      ┌───────────────┐
      │    DONE       │
      │  state = 10   │
      │               │
      │ Output ready: │
      │ crc_out[7:0]  │
      │ done = 1      │
      └───┬───────────┘
          │ (Next cycle)
          └─────────────────┐
                            │
                            ▼
                        ┌────────┐
                        │ Return │
                        │ to     │
                        │ IDLE   │
                        └────────┘
```

---

## 🔗 זרימת הנתונים בפועל

```
CYCLE 1 (T=100ns):
  Driver: "שלח valid=1, data=0xDEADBEEF, poly=0x1D"
    ↓
  Interface: crc_if propagates signals
    ↓
  DUT in IDLE: "מקבל valid & enable"
    ↓
  State → PROCESS

CYCLE 2 (T=110ns):
  DUT in PROCESS: "מחשב CRC"
    crc = calculate_crc(0xDEADBEEF, 0x1D)
    ↓
  State → DONE

CYCLE 3 (T=120ns):
  DUT in DONE:
    crc_out = calculated result (e.g., 0x42)
    done = 1
    ↓
  Monitor: "קורא crc_out=0x42, done=1"
    ↓
  State → IDLE (automatically)

CYCLE 4+ (T=130ns):
  Back to IDLE, ready for next transaction
    ↓
  Predictor: "חשבה expected_crc = 0x42"
    ↓
  Scoreboard: "אם actual==expected → PASS"
```

---

## 📈 ה-Interface - הגשר

```systemverilog
interface crc_if(input clk, input rst_n);
    
    // מהDriver אל ה-DUT:
    logic valid;              // "יש נתון"
    logic enable;             // "בדוק!"
    logic [31:0] data_in;     // הנתון עצמו
    logic [7:0] polynomial;   // הכלל
    
    // מה-DUT בחזרה:
    logic ready;              // "מוכן לעוד"
    logic busy;               // "עדיין עובד"
    logic [7:0] crc_out;      // התוצאה!
    logic error;              // "בעיה!"
    logic done;               // "סיימתי!"
    
    // Clocking blocks (עבור timing נכון):
    clocking dr_cb @(posedge clk);
        output valid, enable, data_in, polynomial;
        input ready, busy, crc_out, error, done;
    endclocking
endinterface
```

---

## 🎯 סיכום קצר

| מה | איפה | עושה |
|---|------|------|
| **Testbench** | `tb/crc_tb_top.sv` | מכיל את כל העולם |
| **Clock** | `tb/crc_tb_top.sv:45` | מבדיל כל 5ns |
| **Reset** | `tb/crc_tb_top.sv:51` | משחרר ב-20ns |
| **Interface** | `src/crc_if.sv` | ממשק של אותות |
| **DUT** | `tb/crc_dut.sv` | חישוב CRC |
| **State Mach** | `tb/crc_dut.sv:30` | IDLE→PROCESS→DONE |
| **CRC Func** | `tb/crc_dut.sv:70` | עושה את החישוב |

---

## 🚀 ריצה בעיניים

```
TEST STARTS
    ↓
Clock & Reset generation
    ↓
DUT في IDLE state
    ↓
Test sends: valid=1, data=0xDEADBEEF, poly=0x1D
    ↓
DUT: "קיבלתי! עובד..."
    ↓
DUT computes: crc = calculate_crc(0xDEADBEEF, 0x1D) = Result
    ↓
DUT outputs: crc_out = Result, done = 1
    ↓
Monitor reads: "תוצאה = Result"
    ↓
Predictor: "צפיתי Result"
    ↓
Scoreboard: "Match! PASS"
    ↓
Repeat 19 more times (smoke test)
    ↓
ALL PASSED!
    ↓
TEST ENDS
```

---

זה הכל! ה-Design זה לא מסובך בכלל - זה פשוט CRC Calculator עם state machine! 🎉
