tictactoe_4x4 : dialog {
    label = "Jogo da Velha 4x4 (Gráfico)";
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
    : boxed_column {
        label = "Regra de Vitória (N em linha)";
        : row {
            : radio_button {
                key = "win_3";           // Chave para 3 em linha
                label = "3 em Linha";
                value = "1";             // Selecionado por padrão
                action = "(set_win_count 3)"; // Função Autolisp a ser chamada
            }
            : radio_button {
                key = "win_4";           // Chave para 4 em linha
                label = "4 em Linha";
                action = "(set_win_count 4)"; // Função Autolisp a ser chamada
            }
        }
    }
//
	: text {
	    label = "Tabuleiro 4x4";
		alignment = centered;
	}
//
    : row {
        : image_button { key = "cell_0_0"; width = 5; height = 3; }
        : image_button { key = "cell_0_1"; width = 5; height = 3; }
        : image_button { key = "cell_0_2"; width = 5; height = 3; }
        : image_button { key = "cell_0_3"; width = 5; height = 3; }
    }
    : row {
        : image_button { key = "cell_1_0"; width = 5; height = 3; }
        : image_button { key = "cell_1_1"; width = 5; height = 3; }
        : image_button { key = "cell_1_2"; width = 5; height = 3; }
        : image_button { key = "cell_1_3"; width = 5; height = 3; }
    }
    : row {
        : image_button { key = "cell_2_0"; width = 5; height = 3; }
        : image_button { key = "cell_2_1"; width = 5; height = 3; }
        : image_button { key = "cell_2_2"; width = 5; height = 3; }
        : image_button { key = "cell_2_3"; width = 5; height = 3; }
    }
    : row {
        : image_button { key = "cell_3_0"; width = 5; height = 3; }
        : image_button { key = "cell_3_1"; width = 5; height = 3; }
        : image_button { key = "cell_3_2"; width = 5; height = 3; }
        : image_button { key = "cell_3_3"; width = 5; height = 3; }
    }
// 
    : text { key = "status"; label = "Sua vez de jogar."; }
	: button { key = "reset"; label = "Reiniciar"; alignment=centered ;width = 8; fixed_width = true;}
//
: image {key = "sep2"; color = dialog_background; width = 1; height = 0.5;}
//
    : row {
		alignment=centered ;
		fixed_width = true;
         : button { key = "sair"; label = "Sair"; width = 10; fixed_width = true; is_cancel = true; }
		 : button { key = "help"; label = " Ajuda "; width = 10; fixed_width = true; is_default = false;}
    }
}

// ======================================================================
//	TicTacToe_4x4_Help.dcl
// ======================================================================
TicTacToe_4x4_Help : dialog {
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