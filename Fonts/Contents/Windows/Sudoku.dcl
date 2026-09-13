// ======================================================================
// SUDOKU.DCL
// Jogo de Sudoku para AutoCAD
// ======================================================================
sudoku : dialog {
    label = "Sudoku";
    
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
    // Controles de Dificuldade
    : row {
        alignment = centered;
		fixed_width = true;
        //: text { label = "Dificuldade:"; alignment = right; width = 10; }
        : radio_row {
            key = "difficulty_group";
			label = "Dificuldade:";
            : radio_button { key = "easy"; label = "Fácil"; }
            : radio_button { key = "medium"; label = "Médio"; }
            : radio_button { key = "hard"; label = "Difícil"; }
            : radio_button { key = "expert"; label = "Expert"; }
        }
    }
    
: image { key = "sep2"; color = dialog_background; width = 1; height = 0.5; }
    
    // Timer e Estatísticas
    : row {
        alignment = centered;
        fixed_width = true;
        : text { key = "timer_display"; label = "Tempo: 00:00"; width = 15; }
        : text { key = "hint_display"; label = "Dicas: 3"; width = 12; }
        : text { key = "mistakes_display"; label = "Erros: 0/3"; width = 12; }
    }
    
    // Grade do Sudoku 9x9 com divisões 3x3
    : column {
       width = 54 ; // 9 células * 6 de largura
       fixed_width = true;
       alignment = centered;
        
        // Linhas do Sudoku com edit_boxes
        : row {
            alignment = centered;
            : edit_box { key = "cell_0_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_0_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_0_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_0_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_0_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_0_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_0_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_0_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_0_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        : row {
            alignment = centered;
            : edit_box { key = "cell_1_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_1_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_1_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_1_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_1_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_1_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_1_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_1_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_1_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        : row {
            alignment = centered;
            : edit_box { key = "cell_2_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_2_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_2_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_2_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_2_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_2_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_2_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_2_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_2_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        
        : spacer { height = 1; }
        
        : row {
            alignment = centered;
            : edit_box { key = "cell_3_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_3_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_3_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_3_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_3_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_3_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_3_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_3_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_3_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        : row {
            alignment = centered;
            : edit_box { key = "cell_4_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_4_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_4_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_4_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_4_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_4_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_4_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_4_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_4_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        : row {
            alignment = centered;
            : edit_box { key = "cell_5_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_5_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_5_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_5_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_5_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_5_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_5_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_5_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_5_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        
        : spacer { height = 1; }
        
        : row {
            alignment = centered;
            : edit_box { key = "cell_6_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_6_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_6_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_6_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_6_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_6_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_6_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_6_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_6_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        : row {
            alignment = centered;
            : edit_box { key = "cell_7_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_7_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_7_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_7_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_7_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_7_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_7_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_7_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_7_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
        : row {
            alignment = centered;
            : edit_box { key = "cell_8_0"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_8_1"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_8_2"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_8_3"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_8_4"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_8_5"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : spacer { width = 1; }
            : edit_box { key = "cell_8_6"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_8_7"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
            : edit_box { key = "cell_8_8"; width = 3; height = 1; edit_width = 2; edit_limit = 1; }
        }
    }
    
    : image { key = "sep3"; color = dialog_background; width = 1; height = 0.5; }
    
    // Status e Controles
    : text { key = "status"; label = "Selecione uma dificuldade e clique em Novo Jogo."; }
    
    : row {
        alignment = centered;
        fixed_width = true;
        
        : button { key = "new_game"; label = "Novo Jogo"; width = 12; fixed_width = true; }
        : button { key = "hint"; label = "Dica"; width = 12; fixed_width = true; }
        : button { key = "check"; label = "Verificar"; width = 12; fixed_width = true; }
        : button { key = "solve"; label = "Resolver"; width = 12; fixed_width = true; }
		}
    : row {
        alignment = centered;
        fixed_width = true;
        
        : button { key = "sair"; label = "Sair"; width = 12; fixed_width = true; is_cancel = true; }
        : button { key = "help"; label = "Ajuda"; width = 12; fixed_width = true; is_default = false; }
    }
}

// ======================================================================
//	Sudoku_Help.dcl
// ======================================================================
Sudoku_Help : dialog {
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
