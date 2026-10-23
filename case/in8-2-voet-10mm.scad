// =============================================================================
// NIXIE IN-8-2 (ИН-8-2) -> TAF1317A (Z570M / B13D) 10mm ADAPTER VOETJE
// =============================================================================
// Robuust massief voetje: rust vlak op de PCB / SMD-transistoren met extra veel
// wanddikte en ruimte rond de kanalen.
// Alle 12 pinnen van de IN-8-2 lopen 100% door (inclusief Pin 8 naar het ongebruikte
// NC-gat op het PCB), zodat er NIETS afgeknipt hoeft te worden!

$fn = 64;

h_seat      = 10.0;   // Hoogte (mm)
h_lip       = 1.0;    // Centreerrand voor glaskolf (mm)
d_outer     = 19.50;  // Buitendiameter (past in Ø 20 mm boorgat)
d_pin_hole  = 1.35;   // Ruime diameter voor soepele geleiding van Ø 0.50 mm draden

// 12 kanalen van IN-8-2 (13-delige cirkel, stap = 360/13 = 27.692°)
// naar de TAF1317A PCB (14-delige cirkel, stap = 360/14 = 25.714°, R = 4.75 mm)
// Pin 8 (PR) gaat naar Pad 4 (het niet-aangesloten NC-gat op het PCB):
channels = [
    [  1 * 360/13, 4.85,  1 * 360/14, 4.750 ], // Pin 12 (Anode) -> Pad 1 (A)
    [  2 * 360/13, 4.85,  2 * 360/14, 4.750 ], // Pin 11 (D0)    -> Pad 2 (0)
    [  3 * 360/13, 4.85,  3 * 360/14, 4.750 ], // Pin 10 (D9)    -> Pad 3 (9)
    [  4 * 360/13, 4.80,  5 * 360/14, 4.750 ], // Pin 9  (D8)    -> Pad 5 (8)
    [  5 * 360/13, 4.95,  4 * 360/14, 4.750 ], // Pin 8  (PR)    -> Pad 4 (NC-R ongebruikt gat)
    [  6 * 360/13, 4.85,  6 * 360/14, 4.750 ], // Pin 7  (D7)    -> Pad 6 (7)
    [  7 * 360/13, 4.85,  7 * 360/14, 4.750 ], // Pin 6  (D6)    -> Pad 7 (6)
    [  8 * 360/13, 4.85,  8 * 360/14, 4.750 ], // Pin 5  (D5)    -> Pad 8 (5)
    [  9 * 360/13, 4.85,  9 * 360/14, 4.750 ], // Pin 4  (D4)    -> Pad 9 (4)
    [ 10 * 360/13, 4.85, 11 * 360/14, 4.750 ], // Pin 3  (D3)    -> Pad 11 (3) [Pad 10 NC-L blijft leeg]
    [ 11 * 360/13, 4.85, 12 * 360/14, 4.750 ], // Pin 2  (D2)    -> Pad 12 (2)
    [ 12 * 360/13, 4.85, 13 * 360/14, 4.750 ]  // Pin 1  (D1)    -> Pad 13 (1)
];

module pin_tunnel(at, rt, ab, rb) {
    // 3D geleiding met radiale bypass tussen Pin 9 en Pin 8
    // We bouwen het kanaal op uit segmenten
    n_seg = 10;
    for (i = [0 : n_seg - 1]) {
        z0 = i * (h_seat / n_seg);
        z1 = (i + 1) * (h_seat / n_seg);
        t0 = z0 / h_seat;
        t1 = z1 / h_seat;
        
        // Hoekinterpolatie
        ang0 = ab + t0 * (at - ab);
        ang1 = ab + t1 * (at - ab);
        
        // Radiale boog voor de kruising tussen D8 en PR
        r_mid_off0 = (at > 105 && at < 115) ? -0.80 * sin(t0 * 180) :
                     (at > 130 && at < 145) ?  1.10 * sin(t0 * 180) : 0;
        r_mid_off1 = (at > 105 && at < 115) ? -0.80 * sin(t1 * 180) :
                     (at > 130 && at < 145) ?  1.10 * sin(t1 * 180) : 0;
                     
        r0 = rb + t0 * (rt - rb) + r_mid_off0;
        r1 = rb + t1 * (rt - rb) + r_mid_off1;
        
        // Extra inlooptrechter aan top
        d0 = (z0 > 7.5) ? d_pin_hole + 0.8 * ((z0 - 7.5) / 2.5) : d_pin_hole;
        d1 = (z1 > 7.5) ? d_pin_hole + 0.8 * ((z1 - 7.5) / 2.5) : d_pin_hole;
        
        hull() {
            translate([r0 * sin(ang0), r0 * cos(ang0), z0 - 0.05])
                cylinder(d = d0, h = 0.1);
            translate([r1 * sin(ang1), r1 * cos(ang1), z1 + 0.05])
                cylinder(d = d1, h = 0.1);
        }
    }
}

difference() {
    // 1. Massief cilindrisch lichaam over volle hoogte
    union() {
        cylinder(d = d_outer, h = h_seat);
        // Centreerlip bovenop voor IN-8-2 glaskolf
        translate([0, 0, h_seat])
            difference() {
                cylinder(d = d_outer, h = h_lip);
                cylinder(d1 = 17.6, d2 = 18.8, h = h_lip + 0.1);
            }
    }

    // 2. Centrale lichtschacht voor WS2812B RGB LED + glazen afsmeltpunt
    translate([0, 0, -0.1])
        cylinder(d = 7.20, h = 2.2); // LED uitsparing
    translate([0, 0, 2.0])
        cylinder(d1 = 7.20, d2 = 6.0, h = 0.8);
    translate([0, 0, 2.7])
        cylinder(d = 6.0, h = h_seat - 2.5);

    // 3. Uitlijnkervje op 12 uur (achterkant tussen Pin 1 en Anode)
    translate([0, d_outer/2, h_seat/2])
        rotate([0, 0, 45])
            cube([1.4, 1.4, h_seat + 2*h_lip], center = true);

    // 4. Alle 12 schuine pinkanalen (100% doorlopend!)
    for (ch = channels) {
        pin_tunnel(ch[0], ch[1], ch[2], ch[3]);
    }
}
