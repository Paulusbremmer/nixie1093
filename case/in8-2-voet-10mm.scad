// =============================================================================
// NIXIE IN-8-2 (ИН-8-2) -> TAF1317A (Z570M / B13D) 10mm ADAPTER VOETJE
// =============================================================================
// Dit 3D-geprinte voetje (10.0 mm hoog + 1.0 mm centreerlip voor het glas)
// geleidt de 12 flexibele pinnen van een Sovjet IN-8-2 buis (13-delige cirkel,
// stap = 27.692°) via schuine interne kanalen automatisch naar de exacte
// 14-delige B13D / Z570M printplaat-gaten (stap = 25.714°, Ø 9.50 mm) op de
// TAF1317A PCB:
// - De 2 ongebruikte NC-gaten op de printplaat (op 3 uur en 9 uur) worden
//   automatisch overgeslagen door de schuine kanalen van Cijfer 8 en Cijfer 3.
// - Pin 8 (PR / rechter komma van de IN-8-2) valt in een blind opvangkanaaltje
//   binnenin het voetje (knip Pin 8 af op ~5–6 mm lengte).
// - De onderzijde heeft een uitsparing voor de WS2812B RGB LED (midden) én een
//   45° vrijloop-afschuining aan de buitenrand zodat de 10 SMD-transistoren
//   (Q0..Q9) rond de buis volledig vrij liggen.
// - Print-oriëntatie: Plat op het printbed (Z = 0 op de bouwplaat), GEEN supports nodig!

$fn = 64;

h_seat      = 10.0;   // Hoogte vanaf printplaat tot onderkant glazen buis (mm)
h_lip       = 1.0;    // Opstaande centreerrand voor de IN-8-2 glaskolf (mm)
d_outer     = 19.50;  // Buitendiameter (past met 0.25mm speling in Ø 20.0 mm boorgat)
d_pcb_ring  = 11.70;  // Diameter van het vlakke draagvlak op de PCB (binnen de SMD transistoren)
d_pin_hole  = 1.28;   // Diameter van de schuine pinkanalen (voor Ø 0.50 mm IN-8-2 draden)

// Kanaal-tabel: [ang_top_deg, r_top, ang_bot_deg, r_bot, z_bot]
// Hoek gemeten met de klok mee vanaf 12 uur (+Y = achterzijde tussen D1 en Anode)
channels = [
    [  1 * 360/13, 4.85,  1 * 360/14, 4.750, -0.1 ], // Pin 12 (Anode) -> Pad 1 (A)
    [  2 * 360/13, 4.85,  2 * 360/14, 4.750, -0.1 ], // Pin 11 (D0)    -> Pad 2 (0)
    [  3 * 360/13, 4.85,  3 * 360/14, 4.750, -0.1 ], // Pin 10 (D9)    -> Pad 3 (9)
    [  4 * 360/13, 4.85,  5 * 360/14, 4.750, -0.1 ], // Pin 9  (D8)    -> Pad 5 (8) [Slaat Pad 4 NC over!]
    [  5 * 360/13, 5.15, 143.5,       6.200,  2.6 ], // Pin 8  (PR)    -> Blind opvangkanaal (stopt op Z=2.6mm)
    [  6 * 360/13, 4.85,  6 * 360/14, 4.750, -0.1 ], // Pin 7  (D7)    -> Pad 6 (7)
    [  7 * 360/13, 4.85,  7 * 360/14, 4.750, -0.1 ], // Pin 6  (D6)    -> Pad 7 (6) [6 uur / Voorkant]
    [  8 * 360/13, 4.85,  8 * 360/14, 4.750, -0.1 ], // Pin 5  (D5)    -> Pad 8 (5)
    [  9 * 360/13, 4.85,  9 * 360/14, 4.750, -0.1 ], // Pin 4  (D4)    -> Pad 9 (4)
    [ 10 * 360/13, 4.85, 11 * 360/14, 4.750, -0.1 ], // Pin 3  (D3)    -> Pad 11 (3) [Slaat Pad 10 NC over!]
    [ 11 * 360/13, 4.85, 12 * 360/14, 4.750, -0.1 ], // Pin 2  (D2)    -> Pad 12 (2)
    [ 12 * 360/13, 4.85, 13 * 360/14, 4.750, -0.1 ]  // Pin 1  (D1)    -> Pad 13 (1)
];

module slanted_pin_channel(at, rt, ab, rb, zb) {
    xt = rt * sin(at);
    yt = rt * cos(at);
    xb = rb * sin(ab);
    yb = rb * cos(ab);

    // Schuin hoofdkanaal van zb tot h_seat
    hull() {
        translate([xb, yb, zb])
            cylinder(d = d_pin_hole, h = 0.05);
        translate([xt, yt, h_seat + 0.05])
            cylinder(d = d_pin_hole, h = 0.05);
    }
    // Radiale inlooptrechter aan de bovenzijde (Z = 7.8 .. 10.0 mm) zodat pinnen makkelijk centreren
    hull() {
        translate([xb + 0.78*(xt-xb), yb + 0.78*(yt-yb), 7.8])
            cylinder(d = d_pin_hole, h = 0.05);
        translate([xt, yt, h_seat + 0.05])
            rotate([0, 0, -at])
                scale([1.3, 1.9, 1.0])
                    cylinder(d = d_pin_hole, h = 0.05);
    }
}

difference() {
    // 1. Hoofdlichaam met SMD-vrijloop aan de onderzijde en glaskolf-kraag aan de bovenzijde
    union() {
        cylinder(d = d_pcb_ring, h = 1.4);
        translate([0, 0, 1.4])
            cylinder(d1 = d_pcb_ring, d2 = d_outer, h = 2.2);
        translate([0, 0, 3.6])
            cylinder(d = d_outer, h = h_seat + h_lip - 3.6);
    }

    // 2. Bovenste kom voor de onderkant van de IN-8-2 glaskolf (Z = 10.0 .. 11.0 mm)
    translate([0, 0, h_seat])
        cylinder(d1 = 17.5, d2 = 18.7, h = h_lip + 0.1);

    // 3. Centrale lichtschacht (voor WS2812B RGB LED onderin + glazen afsmeltpuntje bovenin)
    translate([0, 0, -0.1])
        cylinder(d = 7.10, h = 2.1);
    translate([0, 0, 1.99])
        cylinder(d1 = 7.10, d2 = 5.90, h = 0.82);
    translate([0, 0, 2.8])
        cylinder(d1 = 5.90, d2 = 6.40, h = h_seat - 2.7);

    // 4. 12-uur oriëntatie-inkeping aan de achterzijde (+Y tussen Pin 1 en Anode)
    translate([0, d_outer/2, h_seat/2 + 1.8])
        rotate([0, 0, 45])
            cube([1.3, 1.3, h_seat], center = true);

    // 5. De 12 schuine pinkanalen
    for (ch = channels) {
        slanted_pin_channel(ch[0], ch[1], ch[2], ch[3], ch[4]);
    }
}
