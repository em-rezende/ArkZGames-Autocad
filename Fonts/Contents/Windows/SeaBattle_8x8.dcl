SeaBattle_dialog : dialog {
    label = "SeaBattle (Batalha Naval) contra Inteligencia Artificial (IA)";
//
// ======================================================================
//
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
: image {key = "sep1"; color = dialog_background; width = 1;
height = 0.5;}
//
// ======================================================================
//
: boxed_column {
    label = "Configuração do jogo";
    : row {
        : row {
            : radio_button {
                key = "mode_classic";
                label = "Clássico (6 navios)";
                value = "1";
                fixed_width = true;
            }
            : radio_button {
                key = "mode_fast";
                label = "Rápido (6 navios)";
                value = "0";
                fixed_width = true;
            }
            : radio_button {
                key = "mode_challenge";
                label = "Desafiador (11 navios)";
                value = "0";
                fixed_width = true;
            }
        }
        : spacer { width = 2; }

    }
	: text {
		key = "mode_desc";
		label = " ";
		alignment = left;
		width = 110;
		fixed_width = true;
	}
}
//
// ======================================================================
//
: text {
	key = "turn_status";
	label = "Iniciando o Jogo...";
	width = 70;
	fixed_width = true;
}
: spacer { height = 0.25; }
//
// ======================================================================
//
: row {
    // ----------------------------------------
    // TABULEIRO DO JOGADOR (P) - Seu Navio
    // ----------------------------------------
    : boxed_column {
        label = "SEU TABULEIRO";
        : column { 
	// Células do tabuleiro P_ROW_COL
	
: row { : image_button { key = "cell_P_0_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_0_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_0_2"; width = 4; height = 2; } 
	: image_button { key = "cell_P_0_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_0_4"; width = 4; height = 2; } 
	: image_button { key = "cell_P_0_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_0_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_0_7"; width = 4; height = 2; } }
 
: row { : image_button { key = "cell_P_1_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_1_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_1_2"; width = 4; height = 2; } 
	: image_button { key = "cell_P_1_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_1_4"; width = 4; height = 2; } 
	: image_button { key = "cell_P_1_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_1_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_1_7"; width = 4; height = 2; } }
 
: row { : image_button { key = "cell_P_2_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_2_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_2_2"; width = 4; height = 2; } 
	: image_button { key = "cell_P_2_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_2_4"; width = 4; height = 2; } 
	: image_button { key = "cell_P_2_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_2_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_2_7"; width = 4; height = 2; } }

 : row { : image_button { key = "cell_P_3_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_3_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_3_2"; width = 4; height = 2; } 
	: image_button { key = "cell_P_3_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_3_4"; width = 4; height = 2; }
	: image_button { key = "cell_P_3_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_3_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_3_7"; width = 4; height = 2; } }
			
: row { : image_button { key = "cell_P_4_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_4_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_4_2"; width = 4; height = 2; } 
	: image_button { key = "cell_P_4_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_4_4"; width = 4; height = 2; } 
	: image_button { key = "cell_P_4_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_4_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_4_7"; width = 4; height = 2; } }

: row { : image_button { key = "cell_P_5_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_5_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_5_2"; width = 4; height = 2; } 
	: image_button { key = "cell_P_5_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_5_4"; width = 4; height = 2; } 
	: image_button { key = "cell_P_5_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_5_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_5_7"; width = 4; height = 2; } }
	
 : row { : image_button { key = "cell_P_6_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_6_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_6_2"; width = 4; height = 2; }
	: image_button { key = "cell_P_6_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_6_4"; width = 4; height = 2; } 
	: image_button { key = "cell_P_6_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_6_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_6_7"; width = 4; height = 2; } }

: row { : image_button { key = "cell_P_7_0"; width = 4; height = 2; } 
	: image_button { key = "cell_P_7_1"; width = 4; height = 2; } 
	: image_button { key = "cell_P_7_2"; width = 4; height = 2; } 
	: image_button { key = "cell_P_7_3"; width = 4; height = 2; } 
	: image_button { key = "cell_P_7_4"; width = 4; height = 2; } 
	: image_button { key = "cell_P_7_5"; width = 4; height = 2; } 
	: image_button { key = "cell_P_7_6"; width = 4; height = 2; } 
	: image_button { key = "cell_P_7_7"; width = 4; height = 2; } }
        }
    }
       
    // ----------------------------------------
    // TABULEIRO DO COMPUTADOR (C) - Alvo
    // ----------------------------------------
    : boxed_column {
        label = "TABULEIRO DO INIMIGO (CLIQUE PARA ATIRAR)";
        : column {
            // Células do tabuleiro C_ROW_COL (aceitam clique)
            	: row { : image_button { key = "cell_C_0_0"; width = 4; height = 2; } : image_button { key = "cell_C_0_1"; width = 4; height = 2; } : image_button { key = "cell_C_0_2"; width = 4; height = 2; } : image_button { key = "cell_C_0_3"; width = 4; height = 2; } : image_button { key = "cell_C_0_4"; width = 4; height = 2; } : image_button { key = "cell_C_0_5"; width = 4; height = 2; } : image_button { key = "cell_C_0_6"; width = 4; height = 2; } : image_button { key = "cell_C_0_7"; width = 4; height = 2; } }
            
: row { : image_button { key = "cell_C_1_0"; width = 4; height = 2; } 
	: image_button { key = "cell_C_1_1"; width = 4; height = 2; } 
	: image_button { key = "cell_C_1_2"; width = 4; height = 2; } 
	: image_button { key = "cell_C_1_3"; width = 4; height = 2; } 
	: image_button { key = "cell_C_1_4"; width = 4; height = 2; } 
	: image_button { key = "cell_C_1_5"; width = 4; height = 2; } 
	: image_button { key = "cell_C_1_6"; width = 4; height = 2; } 
	: image_button { key = "cell_C_1_7"; width = 4; height = 2; } }
            
: row { 
	: image_button { key = "cell_C_2_0"; width = 4; height = 2; } 
	: image_button { key = "cell_C_2_1"; width = 4; height = 2; } 
	: image_button { key = "cell_C_2_2"; width = 4; height = 2; } 
	: image_button { key = "cell_C_2_3"; width = 4; height = 2; } 
	: image_button { key = "cell_C_2_4"; width = 4; height = 2; } 
	: image_button { key = "cell_C_2_5"; width = 4; height = 2; } 
	: image_button { key = "cell_C_2_6"; width = 4; height = 2; } 
	: image_button { key = "cell_C_2_7"; width = 4; height = 2; } }
            
: row { 
	: image_button { key = "cell_C_3_0"; width = 4; height = 2; } 
	: image_button { key = "cell_C_3_1"; width = 4; height = 2; } 
	: image_button { key = "cell_C_3_2"; width = 4; height = 2; } 
	: image_button { key = "cell_C_3_3"; width = 4; height = 2; } 
	: image_button { key = "cell_C_3_4"; width = 4; height = 2; } 
	: image_button { key = "cell_C_3_5"; width = 4; height = 2; } 
	: image_button { key = "cell_C_3_6"; width = 4; height = 2; } 
	: image_button { key = "cell_C_3_7"; width = 4; height = 2; } }
            
: row { 
	: image_button { key = "cell_C_4_0"; width = 4; height = 2; } 
	: image_button { key = "cell_C_4_1"; width = 4; height = 2; } 
	: image_button { key = "cell_C_4_2"; width = 4; height = 2; } 
	: image_button { key = "cell_C_4_3"; width = 4; height = 2; } 
	: image_button { key = "cell_C_4_4"; width = 4; height = 2; } 
	: image_button { key = "cell_C_4_5"; width = 4; height = 2; } 
	: image_button { key = "cell_C_4_6"; width = 4; height = 2; } 
	: image_button { key = "cell_C_4_7"; width = 4; height = 2; } }
            
: row { 
	: image_button { key = "cell_C_5_0"; width = 4; height = 2; } 
	: image_button { key = "cell_C_5_1"; width = 4; height = 2; } 
	: image_button { key = "cell_C_5_2"; width = 4; height = 2; } 
	: image_button { key = "cell_C_5_3"; width = 4; height = 2; } 
	: image_button { key = "cell_C_5_4"; width = 4; height = 2; } 
	: image_button { key = "cell_C_5_5"; width = 4; height = 2; } 
	: image_button { key = "cell_C_5_6"; width = 4; height = 2; } 
	: image_button { key = "cell_C_5_7"; width = 4; height = 2; } }
            
: row { 
	: image_button { key = "cell_C_6_0"; width = 4; height = 2; } 
	: image_button { key = "cell_C_6_1"; width = 4; height = 2; } 
	: image_button { key = "cell_C_6_2"; width = 4; height = 2; } 
	: image_button { key = "cell_C_6_3"; width = 4; height = 2; } 
	: image_button { key = "cell_C_6_4"; width = 4; height = 2; } 
	: image_button { key = "cell_C_6_5"; width = 4; height = 2; } 
	: image_button { key = "cell_C_6_6"; width = 4; height = 2; } 
	: image_button { key = "cell_C_6_7"; width = 4; height = 2; } }
            
: row { 
	: image_button { key = "cell_C_7_0"; width = 4; height = 2; } 
	: image_button { key = "cell_C_7_1"; width = 4; height = 2; } 
	: image_button { key = "cell_C_7_2"; width = 4; height = 2; } 
	: image_button { key = "cell_C_7_3"; width = 4; height = 2; } 
	: image_button { key = "cell_C_7_4"; width = 4; height = 2; } 
	: image_button { key = "cell_C_7_5"; width = 4; height = 2; } 
	: image_button { key = "cell_C_7_6"; width = 4; height = 2; } 
	: image_button { key = "cell_C_7_7"; width = 4; height = 2; } }
        }
    }
}
: text {
    label = "Clássico:\n1x Porta-aviões (5)\n1x Couraçado (4)\n2x Cruzador (3)\n1x Destroyer (2)\n1x Submarino (1)\nTotal: 6 navios";
    key = "descricao";
	alignment = left;
    width = 30;
    fixed_width = true;
}
//
// ======================================================================
//
: image {key = "sep3";
color = dialog_background; width = 1; height = 0.5;}
//
: row {
    alignment = centered;
	fixed_width = true;
	: button {
		key = "restart";
		label = "Reiniciar Jogo";
		width = 12;
		fixed_width = true;
	}
	: spacer { width = 35; }
	
	: button {
		key = "cancel";
		label = "Sair";
		width = 12;
		is_cancel = true; }
	: button {
		label = " Ajuda ";
		key = "help";
		width = 12;
		is_default = false;
	}
}
} // end dialog


// ======================================================================
//	SeaBattle_8x8_Help.dcl
// ======================================================================
SeaBattle_8x8_help : dialog {
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
