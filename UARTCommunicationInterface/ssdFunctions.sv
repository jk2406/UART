package ssdDisplay;

  function bit[6:0] CharToSSD(input logic [7:0] ascii);
    begin
      case(ascii)
        // Digits
        "0": CharToSSD = 7'b1000000;
        "1": CharToSSD = 7'b1111001;
        "2": CharToSSD = 7'b0100100;
        "3": CharToSSD = 7'b0110000;
        "4": CharToSSD = 7'b0011001;
        "5": CharToSSD = 7'b0010010;
        "6": CharToSSD = 7'b0000010;
        "7": CharToSSD = 7'b1111000;
        "8": CharToSSD = 7'b0000000;
        "9": CharToSSD = 7'b0010000;

        // Letters A–Z
        "A": CharToSSD = 7'b0001000;
        "B": CharToSSD = 7'b0000011;
        "C": CharToSSD = 7'b1000110;
        "D": CharToSSD = 7'b0100001;
        "E": CharToSSD = 7'b0000110;
        "F": CharToSSD = 7'b0001110;
        "G": CharToSSD = 7'b1000010;
        "H": CharToSSD = 7'b0001001;
        "I": CharToSSD = 7'b1111001;
        "J": CharToSSD = 7'b1110001;
        "K": CharToSSD = 7'b0001010; // approximate
        "L": CharToSSD = 7'b1000111;
        "M": CharToSSD = 7'b0101011; // approx
        "N": CharToSSD = 7'b0101011; // approx
        "O": CharToSSD = 7'b1000000;
        "P": CharToSSD = 7'b0001100;
        "Q": CharToSSD = 7'b0011000;
        "R": CharToSSD = 7'b0001101;
        "S": CharToSSD = 7'b0010010;
        "T": CharToSSD = 7'b0000111;
        "U": CharToSSD = 7'b1000001;
        "V": CharToSSD = 7'b1110001;
        "W": CharToSSD = 7'b0101010; // not perfect
        "X": CharToSSD = 7'b0001001;
        "Y": CharToSSD = 7'b0010001;
        "Z": CharToSSD = 7'b0100100;
        default: CharToSSD = 7'b1111111; // blank (all off)
      endcase
    end
  endfunction

endpackage
