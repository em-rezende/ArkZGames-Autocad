// ======================================================================
// WORDLE.DCL
// Jogo Wordle para AutoCAD com Teclado Virtual usando Image_Buttons
// ======================================================================
wordle : dialog {
    label = "Wordle - Jogo de Palavras";
    
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
                    label = " ";
                    alignment = centered;
                }
            }
        }
    }
    
: image { key = "sep1"; color = dialog_background; width = 1; height = 0.5; }
    
    // Informações do jogo
    : row {
        alignment = centered;
        fixed_width = true;
        : text { key = "attempt_display"; label = "Tentativa: 1/6"; width = 15; }
        : text { key = "word_info"; label = "Palavras: 0"; width = 12; }
    }
    
    // Grade do Wordle 6x5 (6 tentativas, 5 letras)
    : column {
        width = 54;
        fixed_width = true;
        alignment = centered;
        
        // Linhas do Wordle com image_buttons
        : row {
            alignment = centered;
			fixed_width = true;
            : image { key = "cell_1_1"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_1_2"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_1_3"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_1_4"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_1_5"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
        }
        : row {
            alignment = centered;
			fixed_width = true;
            : image { key = "cell_2_1"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_2_2"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_2_3"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_2_4"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_2_5"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
        }
        : row {
            alignment = centered;
			fixed_width = true;
            : image { key = "cell_3_1"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_3_2"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_3_3"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_3_4"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_3_5"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
        }
        : row {
            alignment = centered;
			fixed_width = true;
            : image { key = "cell_4_1"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_4_2"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_4_3"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_4_4"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_4_5"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
        }
        : row {
            alignment = centered;
			fixed_width = true;
            : image { key = "cell_5_1"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_5_2"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_5_3"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_5_4"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_5_5"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
        }
        : row {
            alignment = centered;
			fixed_width = true;
            : image { key = "cell_6_1"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_6_2"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_6_3"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_6_4"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
            : image { key = "cell_6_5"; width = 7; height = 3;   fixed_width = true; fixed_height = true; }
        }
    }
    
: image { key = "sep2"; color = dialog_background; width = 1; height = 0.5; }
    
    // Entrada de palavra
    : row {
        alignment = centered;
        : text { label = "Palavra:"; alignment = right; width = 10; }
        : edit_box { key = "current_word"; width = 25; edit_limit = 5; }
        : button { key = "submit"; label = "Tentar"; width = 10; fixed_width = true; }
    }
    
    // Status
    : text { 
        key = "status"; 
        label = "Digite uma palavra de 5 letras e clique em 'Tentar'."; 
        width = 54;
        fixed_width = true;
        alignment = centered;
    }
    
: image { key = "sep3"; color = dialog_background; width = 1; height = 0.5; }
    
    // TECLADO VIRTUAL COM IMAGE_BUTTON
    : column {
        width = 54;
        fixed_width = true;
        alignment = centered;
        
        // Primeira linha: A-J
        : row {
            alignment = centered;
			fixed_width = true;
            : image_button { key = "key_Q"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_W"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_E"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_R"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_T"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_Y"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_U"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_I"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_O"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_P"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
        }
        // Segunda linha: K-T
        : row {
            alignment = centered;
			fixed_width = true;
			: spacer { width = 2.5; }
            : image_button { key = "key_A"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_S"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_D"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_F"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_G"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_H"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_J"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_K"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_L"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
			: spacer { width = 2.5; }
        }
        // Terceira linha: U-Z + BACK e ENTER
        : row {
            alignment = centered;
			fixed_width = true;
			: spacer { width = 5; }
            : image_button { key = "key_Z"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_X"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_C"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_V"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_B"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_N"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
			: image_button { key = "key_M"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_back"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
            : image_button { key = "key_enter"; width = 4; height = 2; fixed_width = true; fixed_height = true; }
			
        }
    }
    
: image { key = "sep4"; color = dialog_background; width = 1; height = 0.5; }
    
    // Controles do jogo
    : row {
        alignment = centered;
        fixed_width = true;
        
        : button { key = "new_game"; label = "Novo Jogo"; width = 12; fixed_width = true; }
        : button { key = "help"; label = "Ajuda"; width = 12; fixed_width = true; }
        : button { key = "sair"; label = "Sair"; width = 12; fixed_width = true; is_cancel = true; }
    }
}

// ======================================================================
//	wordle_help.dcl
// ======================================================================
wordle_help : dialog {
    label = "Informações sobre o jogo" ;
    : image {
        key = "#img_logo" ;
        alignment=centered ;
        is_tab_stop = false ;
        width = 14;
        aspect_ratio = 0.45;
        fixed_width = true;
        color = dialog_background;
    }
    : list_box {
        width = 65 ;
        height = 16 ;
        key = "lstAbout" ;
        fixed_width = false;
        fixed_width_font = true;
    }
//   : text {
//       label = "Informações de registro do programa:";
//   }
//   : text {
//       key = "reg_dat";
//       fixed_width_font = true;
//       height = 4.5 ;
//   }
    : button {
        fixed_width = true ;
        is_cancel = true ;
        is_default = true ;
        key = "btnOK" ;
        label = "OK" ;
        alignment=centered;		 
        width = 12 ;
    }
} // end dialog
