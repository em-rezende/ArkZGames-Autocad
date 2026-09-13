checkers_dialog : dialog {
    label = "Jogo de Damas contra Inteligência Artificial (IA)";
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
: image {key = "sep1"; color = dialog_background; width = 1; height = 0.5;}
//
//
// ======================================================================
//
: boxed_row {
	label = "Configurações de Jogo";
	: boxed_row {
			label = "Dificuldade da IA (1-5):"; 

			: slider {
				key = "search_depth_slider";
				min_value = 1;
				max_value = 5; // Limite a 5 para evitar longos cálculos
				initial_value = 2; 
				small_increment = 1;
				big_increment = 1;
				width = 15; // Ajuste para melhor visualização
			}
			: text { key = "slider_value_label"; width = 2; label = "2"; } // Label para mostrar o valor (opcional)

	//
	}
	: boxed_row {
		label = "Regra: (Se disponível, é obrigatória)";
		: toggle {
			key = "force_capture_toggle";
			label = "Forçar Captura";
			value = "1"; // Valor inicial (Ativado)
		}
	}
}
//
// ======================================================================
//
: boxed_column {
	label = "Movimento da Inteligência Artificial (IA)";
	: row {
		: toggle {
			key = "pause_toggle";
			label = "Pausa da IA (Clique para Prosseguir)";
			value = "0"; // Valor inicial: Pausa ativada
			width = 40;
		}
		: button {
			key = "continue_button";
			label = "Prosseguir...";
			fixed_width = true;
			is_default = false;
			is_cancel = false;
			action = "(computer_execute_move)"; 
			value = "0"; // Inicialmente oculto/desabilitado
			width = 25;
		}
	}
}

//
// ======================================================================
//
: text {
	key = "turn_status";
	label = "Jogador (O)";
	width = 70;
	fixed_width = true;
}
: spacer { height = 0.25; }
//
// ======================================================================
//
: row {
    : column { // Colunas para alinhar as linhas
        
        // Linha 0
        : row {
            : image_button { key = "cell_0_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_0_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_0_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_0_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_0_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_0_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_0_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_0_7"; width = 4; height = 3.5;   }
        }
        // Linha 1
        : row {
            : image_button { key = "cell_1_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_1_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_1_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_1_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_1_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_1_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_1_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_1_7"; width = 4; height = 3.5;   }
        }
        // Linha 2
        : row {
            : image_button { key = "cell_2_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_2_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_2_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_2_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_2_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_2_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_2_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_2_7"; width = 4; height = 3.5;   }
        }
        // Linha 3
        : row {
            : image_button { key = "cell_3_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_3_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_3_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_3_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_3_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_3_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_3_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_3_7"; width = 4; height = 3.5;   }
        }
        // Linha 4
        : row {
            : image_button { key = "cell_4_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_4_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_4_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_4_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_4_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_4_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_4_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_4_7"; width = 4; height = 3.5;   }
        }
        // Linha 5
        : row {
            : image_button { key = "cell_5_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_5_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_5_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_5_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_5_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_5_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_5_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_5_7"; width = 4; height = 3.5;   }
        }
        // Linha 6
        : row {
            : image_button { key = "cell_6_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_6_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_6_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_6_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_6_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_6_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_6_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_6_7"; width = 4; height = 3.5;   }
        }
        // Linha 7
        : row {
            : image_button { key = "cell_7_0"; width = 4; height = 3.5;   }
            : image_button { key = "cell_7_1"; width = 4; height = 3.5;   }
            : image_button { key = "cell_7_2"; width = 4; height = 3.5;   }
            : image_button { key = "cell_7_3"; width = 4; height = 3.5;   }
            : image_button { key = "cell_7_4"; width = 4; height = 3.5;   }
            : image_button { key = "cell_7_5"; width = 4; height = 3.5;   }
            : image_button { key = "cell_7_6"; width = 4; height = 3.5;   }
            : image_button { key = "cell_7_7"; width = 4; height = 3.5;   }
        }
    }
}
//
// ======================================================================
//
: boxed_row {
    label = "Salvar / Carregar";
	alignment = centered;
	fixed_width = true;

        : button {
            key = "save_state_button";
            label = "Gravar Posição";
            width = 15;
            alignment = left;
			fixed_width = true;
        }
        : button {
            key = "load_state_button";
            label = "Carregar Posição";
            width = 15;
            alignment = left;
			fixed_width = true;
        }
    : button {
        key = "save_notation_button";
        label = "Gravar Partida (Notação)";
        width = 25;
        alignment = centered;
		fixed_width = true;
    }		


}
//
// ======================================================================
//
: image {key = "sep3"; color = dialog_background; width = 1; height = 0.5;}
//
: row {
	: button {
		key = "restart";
		label = "Reiniciar Jogo";
		width = 25;
		fixed_width = true;
	}
		: spacer { width = 1; }
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
//	Checkers_8x8_help.dcl
// ======================================================================
Checkers_8x8_help : dialog {
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
