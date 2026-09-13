// ======================================================================
// 2048.DCL - Versão com IMAGE_BUTTON para movimentos
// ======================================================================
game2048 : dialog {
    label = "2048";
    
    : row {
        alignment = centered;
        fixed_width = true;
        fixed_height = true;
        : image {
            key = "#img_logo";
            alignment = centered;
            fixed_width = true;
            fixed_height = true;
            is_tab_stop = false;
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
: image { key = "sep1"; color = dialog_background; width = 1; height = 0.5; }
// 
    // Pontuação e Controles
    : row {
        alignment = centered;
        fixed_width = true;
        : text { key = "score_display"; label = "Pontuação: 0"; width = 20; }
        : text { key = "best_display"; label = "Recorde: 0"; width = 20; }
        : text { key = "moves_display"; label = "Movimentos: 0"; width = 20; }
    }
    
    : row {
        alignment = centered;
        fixed_width = true;
        : text { key = "status"; label = "Use as setas para mover os números"; width = 50; }
    }

: row {
	width = 40;
	alignment = centered;
	fixed_width = true;

    // Grade 4x4 do jogo 2048 (com IMAGE tiles)
    : column {
        fixed_width = true;
        alignment = centered;
		 
        : row {
            alignment = centered;
		    fixed_width = true;
            : image { key = "tile_0_0"; width = 6; height = 2; }
            : image { key = "tile_0_1"; width = 6; height = 2; }
            : image { key = "tile_0_2"; width = 6; height = 2; }
            : image { key = "tile_0_3"; width = 6; height = 2; }
        }
        : row {
            alignment = centered;
		    fixed_width = true;
            : image { key = "tile_1_0"; width = 6; height = 2; }
            : image { key = "tile_1_1"; width = 6; height = 2; }
            : image { key = "tile_1_2"; width = 6; height = 2; }
            : image { key = "tile_1_3"; width = 6; height = 2; }
        }
        : row {
            alignment = centered;
		    fixed_width = true;
            : image { key = "tile_2_0"; width = 6; height = 2; }
            : image { key = "tile_2_1"; width = 6; height = 2; }
            : image { key = "tile_2_2"; width = 6; height = 2; }
            : image { key = "tile_2_3"; width = 6; height = 2; }
        }
        : row {
            alignment = centered;
		    fixed_width = true;
            : image { key = "tile_3_0"; width = 6; height = 2; }
            : image { key = "tile_3_1"; width = 6; height = 2; }
            : image { key = "tile_3_2"; width = 6; height = 2; }
            : image { key = "tile_3_3"; width = 6; height = 2; }
        }
    }
    : spacer { width = 2; }
    // Controles - AGORA COM IMAGE_BUTTON
	: column {
		alignment = centered;
		fixed_width = true;
		: spacer { height = 1; }
		: row {
			alignment = centered;
			width = 20;
			fixed_width = true;
			: spacer { width = 2; }
			: image_button { key = "btn_up"; width = 3; height = 3; }
			: spacer { width = 2; }
		}
		: row {
			alignment = centered;
			width = 20;
			fixed_width = true;
			: image_button { key = "btn_left"; width = 6; height = 3; }
			: spacer { width = 4; }
			: image_button { key = "btn_right"; width = 6; height = 3; }
		}
		: row {
			alignment = centered;
			width = 20;
			fixed_width = true;
			: spacer { width = 2; }
			: image_button { key = "btn_down"; width = 3; height = 3; }
			: spacer { width = 2; }
		}
		: spacer { height = 1; }
	}
}

	: row {
		alignment = centered;
		fixed_width = true;
		: button { key = "btn_reset"; label = "Novo Jogo"; width = 12; fixed_width = true; }
		: button { key = "btn_undo"; label = "Desfazer"; width = 12; fixed_width = true; }			
	
	}
//
: image { key = "sep2"; color = dialog_background; width = 1; height = 0.5; }
// 
	: row {
		alignment = centered;
		fixed_width = true;
		
		: button { key = "sair"; label = "Sair"; width = 10; fixed_width = true; is_cancel = true; }
		: button { key = "help"; label = "Ajuda"; width = 10; fixed_width = true; is_default = false; }
	}
}


// ======================================================================
//	Game2048_Help.dcl
// ======================================================================
Game2048_Help : dialog {
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
