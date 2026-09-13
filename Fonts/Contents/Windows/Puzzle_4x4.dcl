puzzle_4x4 : dialog {
    label = "Puzzle Deslizante 4x4 (15-Puzzle)";

// ======================================================================
// (Estrutura de Cabeçalho e Logo - Reutilizada do 3x3)
// ======================================================================

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

: column {
	width = 35 ; 
	fixed_width = true;
	alignment = centered;
    
    // LINHA 0
    : row { 
        : image_button { key = "cell_0_0"; width = 4; height = 3;}
        : image_button { key = "cell_0_1"; width = 4; height = 3;}
        : image_button { key = "cell_0_2"; width = 4; height = 3;}
        : image_button { key = "cell_0_3"; width = 4; height = 3;}
    }
    // LINHA 1
    : row { 
        : image_button { key = "cell_1_0"; width = 4; height = 3;}
        : image_button { key = "cell_1_1"; width = 4; height = 3;}
        : image_button { key = "cell_1_2"; width = 4; height = 3;}
        : image_button { key = "cell_1_3"; width = 4; height = 3;}
    }
    // LINHA 2
    : row { 
        : image_button { key = "cell_2_0"; width = 4; height = 3;}
        : image_button { key = "cell_2_1"; width = 4; height = 3;}
        : image_button { key = "cell_2_2"; width = 4; height = 3;}
        : image_button { key = "cell_2_3"; width = 4; height = 3;}
    }
    // LINHA 3
    : row { 
        : image_button { key = "cell_3_0"; width = 4; height = 3;}
        : image_button { key = "cell_3_1"; width = 4; height = 3;}
        : image_button { key = "cell_3_2"; width = 4; height = 3;}
        : image_button { key = "cell_3_3"; width = 4; height = 3;}
    }
}
//
: image {key = "sep2"; color = dialog_background; width = 1; height = 0.5;}
//
: text { key = "status"; label = "Clique para embaralhar e começar."; }
//
: image {key = "sep3"; color = dialog_background; width = 1; height = 0.5;}
//
	: row {
		alignment = centered;
		fixed_width = true;
		: button {
			key = "reset";
			label = "Reiniciar";
			width = 10;
			fixed_width = true;
		}
		: button {
			key = "sair";
			label = "Sair";
			width = 10;
			is_cancel = true;
		}
		: button {
			label = " Ajuda ";
			key = "help";
			width = 10;
			is_default = false;
		}
	
	}
	
} // end dialog


// ======================================================================
//	P4_Puzzle_Help.dcl
// ======================================================================
P4_Puzzle_Help : dialog {
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
