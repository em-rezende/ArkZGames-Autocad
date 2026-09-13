hanoi_dialog : dialog {
  label = "Torre de Hanoi";
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

: row {
	: column {
		: image_button {
		key = "img_a";
		width = 20;
		height = 12;
		color = 0;
		}
		: text {
		key = "txt_a";
		label = "Torre A: 0";
		alignment = centered;
		}
	}
	: column {
		: image_button {
		key = "img_b";
		width = 20;
		height = 12;
		color = 0;
		}
		: text {
		key = "txt_b";
		label = "Torre B: 0";
		alignment = centered;
		}
	}
	: column {
		: image_button {
		key = "img_c";
		width = 20;
		height = 12;
		color = 0;
		}
		: text {
		key = "txt_c";
		label = "Torre C: 0";
		alignment = centered;
		}
	}
}
//
: row {
	alignment = centered;
	fixed_width = true;

: boxed_row {
	label = "Número de discos";

	: slider {
		key = "slider_discos";
		min_value = 3;
		max_value = 8;
		value = 3;
		width = 15;
		height = 5;
	}
		: spacer { width = 2 ; }
		: text {
		key = "txt_discos_valor";
		label = "3";
		width = 5;
	}
}
    : spacer { width = 2 ; }
	: button {
		key = "btn_reset";
		label = " Reiniciar ";
		width = 12;
		fixed_width = true;
	}
}
//
: boxed_column {
	label = "Status";
	: text {
		key = "txt_status";
		label = "Pronto para começar...";
	}
	: text {
		key = "txt_movimentos";
		label = "Movimentos: 0";
	}
	: text {
		key = "txt_minimo";
		label = "Mínimo: 7";
	}
}
//
: image {key = "sep2"; color = dialog_background; width = 1; height = 0.5;}
//
: row {
	alignment = centered;
	fixed_width = true;

	: button {
		key = "help";
		label = " Ajuda ";
		width = 12;
		fixed_width = true;
	}
	: button {
		key = "accept";
		label = " Sair ";
		is_default = true;
		width = 12;
		fixed_width = true;
	}
}
}

// ======================================================================
//	Hanoi_help.dcl
// ======================================================================
Hanoi_help : dialog {
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
