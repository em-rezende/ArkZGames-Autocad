// ======================================================================
// MINESWEEPER_8X8.DCL
// Jogo de Campo Minado Simplificado (8x8)
// ======================================================================
minesweeper_8x8 : dialog {
    label = "Campo Minado Simplificado 8x8";
: row {
	alignment = centered;
	fixed_width = true;
	fixed_height = true;  
	: image {
		key = "#img_logo" ;
		alignment = centered;
		fixed_width = true;
		fixed_height = true;    
		is_tab_stop = false ;
		width = 14;
		aspect_ratio = 0.45;
		color = dialog_background;
	}
	: column {
		: paragraph {
			key = "#arkz";
			: text_part {
				label = " ";
				alignment = centered;
			}
			: text_part {
				label = "Ark-Z Arquitetura Ltda";
				alignment = centered;
			}
			: text_part {
				label = "by Ezequiel M Rezende";
				alignment = centered;
			}
		}
	}	
}
//
: image {key = "sep1"; color = dialog_background; width = 1; height = 0.5;}
//
    // Controle de Dificuldade (Slider para Minas)
    : row {
        alignment = centered;
        : text { label = "Nº de Minas (8-54):"; alignment = right; }
        : slider { 
            key = "mine_slider"; 
            min_value = 8;        // Mínimo razoável para 8x8
            max_value = 54;       // Máximo (64 células - 10 padrão)
            initial_value = 10;   // Valor inicial padrão
            small_increment = 1; 
            big_increment = 5; 
            width = 20; 
            action = "(MS_update_slider_display $value)"; 
        }
        : text { key = "slider_value_display"; label = "10"; width = 4; alignment = left; }
    }

//
: image { key = "sep_dif"; color = dialog_background; width = 1; height = 0.5; }
//

// Contadores de Minas e Células Restantes (Opcional, mas útil)
	: row {
		alignment = centered;
		fixed_width = true;
		: text { key = "mine_count_display"; label = "Minas: "; width = 20; }
		: text { key = "cells_remaining_display"; label = "Restantes: "; width = 15; }
	} 
	
// Grade do Campo Minado (8x8)
    : column {
        width = 48; // Acomoda 8 botões de largura 5 + espaços
        fixed_width = true;
        alignment = centered;
        
        // Criação das 8 linhas de botões
	: row { key = "row_0"; 
		: image_button { key = "cell_0_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_0_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_0_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_0_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_0_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_0_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_0_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_0_7"; width = 5; height = 2.5; } 
	}
	
	: row { key = "row_1"; 
		: image_button { key = "cell_1_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_1_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_1_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_1_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_1_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_1_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_1_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_1_7"; width = 5; height = 2.5; } 
	}
	
	: row { key = "row_2"; 
		: image_button { key = "cell_2_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_2_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_2_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_2_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_2_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_2_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_2_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_2_7"; width = 5; height = 2.5; } 
	}
	
	: row { key = "row_3"; 
		: image_button { key = "cell_3_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_3_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_3_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_3_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_3_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_3_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_3_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_3_7"; width = 5; height = 2.5; } 
	}
	
	: row { key = "row_4"; 
		: image_button { key = "cell_4_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_4_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_4_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_4_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_4_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_4_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_4_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_4_7"; width = 5; height = 2.5; } 
	}
	
	: row { key = "row_5"; 
		: image_button { key = "cell_5_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_5_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_5_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_5_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_5_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_5_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_5_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_5_7"; width = 5; height = 2.5; } 
	}
	
	: row { key = "row_6"; 
		: image_button { key = "cell_6_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_6_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_6_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_6_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_6_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_6_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_6_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_6_7"; width = 5; height = 2.5; } 
	}
	
	: row { key = "row_7"; 
		: image_button { key = "cell_7_0"; width = 5; height = 2.5; } 
		: image_button { key = "cell_7_1"; width = 5; height = 2.5; } 
		: image_button { key = "cell_7_2"; width = 5; height = 2.5; } 
		: image_button { key = "cell_7_3"; width = 5; height = 2.5; } 
		: image_button { key = "cell_7_4"; width = 5; height = 2.5; } 
		: image_button { key = "cell_7_5"; width = 5; height = 2.5; } 
		: image_button { key = "cell_7_6"; width = 5; height = 2.5; } 
		: image_button { key = "cell_7_7"; width = 5; height = 2.5; } 
	}

    }
//
: image { key = "sep2"; color = dialog_background; width = 1; height = 0.5; }
//
    // Status e Controles
    : text { key = "status"; label = "Clique em Reiniciar para começar."; }
    
    : row {
        alignment = centered;
        fixed_width = true;
        
        : button { key = "reset"; label = "Reiniciar"; width = 10; fixed_width = true; }
        : button { key = "sair"; label = "Sair"; width = 10; fixed_width = true; is_cancel = true; }
        : button { key = "help"; label = " Ajuda "; width = 10; fixed_width = true; is_default = false; }
    }
}


// ======================================================================
//	Minesweeper_8x8_Help.dcl
// ======================================================================
Minesweeper_8x8_Help : dialog {
    label = "Informações sobre Ark-Z Arquitetura";
    : image {
        key = "#img_logo";
        alignment = centered;
        is_tab_stop = false;
        width = 14;
        aspect_ratio = 0.45;
        fixed_width = true;
        color = dialog_background;
    }
    : list_box {
        width = 65;
        height = 16;
        key = "lstAbout";
        fixed_width = false;
        fixed_width_font = true;
    }
    : text { label = "Informações do desenvolvedor:"; }
    : text { key = "reg_dat"; fixed_width_font = true; height = 4.5; }
    : button {
        fixed_width = true;
        is_cancel = true;
        is_default = true;
        key = "btnOK";
        label = "OK";
        alignment = centered;
        width = 12;
    }
}  // end dialog
