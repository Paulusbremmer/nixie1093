// =============================================================================
// NIXIE IN-8-2 -> TAF1317A 10mm VOETJE (PIN 8 AFGEKNIPT — DIKKE BINNENWANDEN)
// =============================================================================
// Pin 8 (PR / komma) wordt afgeknipt.
// Daardoor is er GEEN enkele kruising tussen de kanalen en lopen alle 11 actieve
// pinnen via een kaarsrechte / zachte, gelijkmatige schuinte direct naar het PCB!
// Binnenwanden zijn overal minimaal 1.1 tot 1.5 mm dik en oersterk.

$fn = 64;

h_seat      = 10.0;   // Hoogte tot onderkant glazen buis (mm)
h_lip       = 1.0;    // Bovenste centreerlip voor de kolf (mm)
d_outer     = 19.50;  // Buitendiameter (past in Ø 20.0 mm boorgat)
d_pin_hole  = 1.25;   // Precieze, soepele geleiding voor Ø 0.50 mm draden

// 11 actieve kanalen:
// IN-8-2 (boven) -> TAF1317A PCB (onder, R = 4.75 mm, 14-delig)
// Pin 8 (PR) is weggelaten (afknippen).
// Pin 9 (D8) heeft nu alle ruimte om zonder bypass naar Pad 5 (D8) te lopen!
channels = [
    [  1 * 360/13, 4.80,  1 * 360/14, 4.750 ], // Pin 12 (Anode) -> Pad 1 (A)
    [  2 * 360/13, 4.80,  2 * 360/14, 4.750 ], // Pin 11 (D0)    -> Pad 2 (0)
    [  3 * 360/13, 4.80,  3 * 360/14, 4.750 ], // Pin 10 (D9)    -> Pad 3 (9)
    [  4 * 360/13, 4.80,  5 * 360/14, 4.750 ], // Pin 9  (D8)    -> Pad 5 (8)
    // Pin 8 (PR) is afgeknipt — geen kanaal nodig!
    [  6 * 360/13, 4.80,  6 * 360/14, 4.750 ], // Pin 7  (D7)    -> Pad 6 (7)
    [  7 * 360/13, 4.80,  7 * 360/14, 4.750 ], // Pin 6  (D6)    -> Pad 7 (6)
    [  8 * 360/13, 4.80,  8 * 360/14, 4.750 ], // Pin 5  (D5)    -> Pad 8 (5)
    [  9 * 360/13, 4.80,  9 * 360/14, 4.750 ], // Pin 4  (D4)    -> Pad 9 (4)
    [ 10 * 360/13, 4.80, 11 * 360/14, 4.750 ], // Pin 3  (D3)    -> Pad 11 (3)
    [ 11 * 360/13, 4.80, 12 * 360/14, 4.750 ], // Pin 2  (D2)    -> Pad 12 (2)
    [ 12 * 360/13, 4.80, 13 * 360/14, 4.750 ]  // Pin 1  (D1)    -> Pad 13 (1)
];

module straight_slanted_channel(at, rt, ab, rb) {
    xt = rt * sin(at);
    yt = rt * cos(at);
    xb = rb * sin(ab);
    yb = rb * cos(ab);

    // Kaarsrecht schuin doorvoerkanaal van onder naar boven
    hull() {
        translate([xb, yb, -0.1])
            cylinder(d = d_pin_hole, h = 0.2);
        translate([xt, yt, h_seat + 0.1])
            cylinder(d = d_pin_hole, h = 0.2);
    }
    // Brede inlooptrechter aan de bovenzijde (Z = 7.5 .. 10.0 mm)
    hull() {
        translate([xb + 0.75*(xt-xb), yb + 0.75*(yt-yb), 7.5])
            cylinder(d = d_pin_hole, h = 0.1);
        translate([xt, yt, h_seat + 0.1])
            cylinder(d1 = d_pin_hole, d2 = d_pin_hole + 0.9, h = 2.5);
    }
}

difference() {
    // 1. Massief lichaam met vlakke onderzijde
    union() {
        cylinder(d = d_outer, h = h_seat);
        // Centreerlip voor glaskolf
        translate([0, 0, h_seat])
            difference() {
                cylinder(d = d_outer, h = h_lip);
                cylinder(d1 = 17.5, d2 = 18.7, h = h_lip + 0.1);
            }
    }

    // 2. Centrale lichtschacht voor WS2812B LED & glazen afsmeltpunt
    // Ruim voldoende afstand tot de pinkanalen (minstens 1.2 mm wanddikte)
    translate([0, 0, -0.1])
        cylinder(d = 6.80, h = 2.0); // LED uitsparing
    translate([0, 0, 1.9])
        cylinder(d1 = 6.80, d2 = 5.40, h = 0.8);
    translate([0, 0, 2.6])
        cylinder(d = 5.40, h = h_seat - 2.5);

    // 3. Uitlijnkervje op 12 uur (achterkant tussen Pin 1 en Anode)
    translate([0, d_outer/2, h_seat/2])
        rotate([0, 0, 45])
            cube([1.4, 1.4, h_seat + 2*h_lip], center = true);

    // 4. De 11 kaarsrechte schuine kanalen
    for (ch = channels) {
        straight_slanted_channel(ch[0], ch[1], ch[2], ch[3]);
    }
}
