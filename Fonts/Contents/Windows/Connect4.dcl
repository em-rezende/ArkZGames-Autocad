connect4_dialog : dialog {
    label = "Jogo Conecta 4 (4 em Linha) contra IA";

    // ======================================================================
    // LOGO E TÍTULO (Mantido o formato do Damas_8x8.dcl)
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
: image {key = "sep1"; color = dialog_background; width = 1; height = 0.5;}
    
    // ======================================================================
    // CONFIGURAÇÕES E DIFICULDADE DA IA
    // ======================================================================
: column {
	: row {
			label = "Configurações de Jogo";
			: boxed_row {
				label = "Dificuldade da IA (1-7):";
				: slider {
					key = "search_depth_slider";
					min_value = 1; max_value = 7; initial_value = 4; 
					small_increment = 1; big_increment = 1; width = 15;
				}
				: text { key = "slider_value_label"; width = 2; label = "4";}
			}
			
			// PAUSA DA IA (Habilitar/Desabilitar)
			: boxed_row {
				label = "Controle de Turno:";
				: toggle { 
					key = "pause_toggle"; 
					label = "Pausar IA a cada jogada";
					value = "0"; // Inicia desativado
				}
				: button {
					key = "continue_button";
					label = "Prosseguir (IA)";
					width = 18;
					is_default = false;
					// Inicialmente invisível/desabilitado.
					// Controlado pelo LISP com mode_tile.
				}
			}
	}
//
	: row {
	: boxed_row {
		label = "Conexões Necessárias (3, 4 ou 5):";
		alignment = left;
		fixed_width = true;
		: slider {
			key = "connect_slider";
			min_value = 3;  max_value = 5;  value = "4"; 
			small_increment = 1; big_increment = 1;
			width = 18; fixed_width = true;
			}
		: text {
			key = "connect_value_label";
			value = "4"; /* Valor inicial */
			width = 2;
			fixed_width = true;
		}
		: spacer { width = 15; }
		}
		: button {
			key = "restart";
			label = "Reiniciar Jogo";
			width = 18;
			fixed_width = true;
		}
	}
}

//
    // ======================================================================
    // STATUS DO JOGO
    // ======================================================================
    : image {key = "sep2"; color = dialog_background; width = 1; height = 0.5;}
    : text { 
        key = "turn_status"; 
        label = "JOGADOR (Sua Vez)"; 
        width = 60; 
        fixed_width = true; 
        alignment = centered;
    }
    : spacer { height = 0.25; }

    // ======================================================================
    // TABULEIRO (6 LINHAS x 7 COLUNAS)
    // ======================================================================
    : row { 
        alignment = centered;
        : column {
            
            // LINHA 0 (TOPO)
            : row {
                : image_button { key = "cell_0_0"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_0_1"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_0_2"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_0_3"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_0_4"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_0_5"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_0_6"; width = 3.5; height = 3.5; }
            }
            
            // LINHA 1
            : row {
                : image_button { key = "cell_1_0"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_1_1"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_1_2"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_1_3"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_1_4"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_1_5"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_1_6"; width = 3.5; height = 3.5; }
            }
            
            // LINHA 2
            : row {
                : image_button { key = "cell_2_0"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_2_1"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_2_2"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_2_3"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_2_4"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_2_5"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_2_6"; width = 3.5; height = 3.5; }
            }
            
            // LINHA 3
            : row {
                : image_button { key = "cell_3_0"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_3_1"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_3_2"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_3_3"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_3_4"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_3_5"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_3_6"; width = 3.5; height = 3.5; }
            }
            
            // LINHA 4
            : row {
                : image_button { key = "cell_4_0"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_4_1"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_4_2"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_4_3"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_4_4"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_4_5"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_4_6"; width = 3.5; height = 3.5; }
            }
            
            // LINHA 5 (BASE)
            : row {
                : image_button { key = "cell_5_0"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_5_1"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_5_2"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_5_3"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_5_4"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_5_5"; width = 3.5; height = 3.5; }
                : image_button { key = "cell_5_6"; width = 3.5; height = 3.5; }
            }
        }
    }
    
    : image {key = "sep3"; color = dialog_background; width = 1; height = 0.5;}
    
    // ======================================================================
    // BOTÕES DE CONTROLE
    // ======================================================================
    : row {
		alignment = centered;
		fixed_width = true; 
        : button {
            key = "cancel";
            label = "Sair";
            width = 12;
			fixed_width = true; 
            is_cancel = true;
        }
        : button {
            label = " Ajuda ";
            key = "help";
            width = 12;
			fixed_width = true; 
            is_default = false;
        }
    }
    
} // end dialog conect4_dialog


// ======================================================================
//	Connect4_help.dcl
// ======================================================================
Connect4_help : dialog {
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
