;; ======================================================================
;; 2048.LSP - Jogo 2048 para AutoCAD - VERSÃO COM IMAGE_BUTTON
;; ======================================================================
;; - Início: 2025/12/16 - Ezequiel M Rezende
;; - Com total ajuda do DeepSeek


;; Variáveis globais
(setq G2048_dcl_id nil)
(setq G2048_board nil)          ;; Tabuleiro 4x4
(setq G2048_previous_board nil) ;; Para desfazer
(setq G2048_score 0)
(setq G2048_best_score 0)
(setq G2048_moves 0)
(setq G2048_game_over nil)
(setq G2048_won nil)

;; Mapeamento de valores para slides
(setq G2048_slide_map '(
    (0    "EMPTY"     253)   ;; Célula vazia - cinza claro
    (2    "G2"        12)     ;; 2 - vermelho
    (4    "G4"        30)     ;; 4 - amarelo
    (8    "G8"        82)     ;; 8 - verde
    (16   "G16"       122)     ;; 16 - ciano
    (32   "G32"       152)     ;; 32 - azul
    (64   "G64"       212)     ;; 64 - magenta
    (128  "G128"      32)    ;; 128 - laranja
    (256  "G256"      95)    ;; 256 - verde claro
    (512  "G512"      133)   ;; 512 - azul claro
    (1024 "G1024"     203)   ;; 1024 - rosa
    (2048 "G2048"     45)   ;; 2048 - dourado
))

;; Mapeamento para botões de movimento
(setq G2048_button_slides '(
    ("btn_up"    "up"     -2)     ;; Botão para cima
    ("btn_down"  "down"   -2)     ;; Botão para baixo
    ("btn_left"  "left"   -2)     ;; Botão para esquerda
    ("btn_right" "right"  -2)     ;; Botão para direita
))

;; ======================================================================
;; FUNÇÕES PARA EXIBIR SLIDES
;; ======================================================================

(defun G2048_ShowSld (tile slide color_index / x y)
  ;; Exibe slide em um tile (para tiles do tabuleiro)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  
  (fill_image 0 0 x y color_index) 
  
  (slide_image 0 0 x y
    (strcat "Game2048" " (" slide ")")
  )
  (end_image)
)

(defun G2048_ShowButtonSld (button slide color_index / x y)
  ;; Exibe slide em um image_button (para botões de movimento)
  (setq x (dimx_tile button))
  (setq y (dimy_tile button))
  (start_image button)
  
  (fill_image 0 0 x y color_index) 
  
  (slide_image 0 0 x y
    (strcat "Game2048" " (" slide ")")
  )
  (end_image)
)

(defun G2048_get_slide_info (value)
  ;; Retorna (slide_name color_index) para um valor do tabuleiro
  (setq slide_name "EMPTY")
  (setq color_index 253)  ;; Cinza padrão para vazio
  
  (foreach mapping G2048_slide_map
    (if (= (car mapping) value)
      (progn
        (setq slide_name (cadr mapping))
        (setq color_index (caddr mapping))
      )
    )
  )
  
  (list slide_name color_index)
)

(defun G2048_setup_buttons ()
  ;; Configura todos os botões de movimento com slides
  (foreach button_info G2048_button_slides
    (setq button (car button_info))
    (setq slide (cadr button_info))
    (setq color_index 254 )
    
    (G2048_ShowButtonSld button slide color_index)
  )
)

;; ======================================================================
;; FUNÇÕES AUXILIARES
;; ======================================================================

(defun G2048_make_range (start end / result)
  (setq result nil)
  (while (<= start end)
    (setq result (cons end result))
    (setq end (1- end))
  )
  (reverse result)
)

(defun G2048_get_cell (board row col)
  (if (and (< row 4) (< col 4) (>= row 0) (>= col 0))
    (nth col (nth row board))
    0
  )
)

(defun G2048_set_cell (board row col value)
  (setq new_board '())
  (setq i 0)
  
  (foreach row_data board
    (if (= i row)
      (progn
        (setq new_row '())
        (setq j 0)
        (foreach cell row_data
          (if (= j col)
            (setq new_row (cons value new_row))
            (setq new_row (cons cell new_row))
          )
          (setq j (1+ j))
        )
        (setq new_board (cons (reverse new_row) new_board))
      )
      (setq new_board (cons row_data new_board))
    )
    (setq i (1+ i))
  )
  (reverse new_board)
)

(defun G2048_randnum (/ modulus multiplier increment)
  (setq modulus    65536
        multiplier 25173
        increment  13849)
  (setq *G2048_seed* (if (not *G2048_seed*) (getvar "DATE") *G2048_seed*))
  (setq *G2048_seed* (rem (+ (* *G2048_seed* multiplier) increment) modulus))
  (/ *G2048_seed* modulus)
)

(defun G2048_get_empty_cells (board / empty_cells row_idx col_idx)
  (setq empty_cells '())
  (setq row_idx 0)
  
  (foreach row board
    (setq col_idx 0)
    (foreach cell row
      (if (= cell 0)
        (setq empty_cells (cons (list row_idx col_idx) empty_cells))
      )
      (setq col_idx (1+ col_idx))
    )
    (setq row_idx (1+ row_idx))
  )
  
  empty_cells
)

(defun G2048_add_random_tile (board / empty_cells pos row col value)
  (setq empty_cells (G2048_get_empty_cells board))
  
  (if empty_cells
    (progn
      ;; Escolhe célula aleatória
      (setq pos (nth (fix (* (G2048_randnum) (length empty_cells))) empty_cells))
      (setq row (car pos))
      (setq col (cadr pos))
      
      ;; 90% de chance para 2, 10% para 4
      (setq value (if (< (G2048_randnum) 0.9) 2 4))
      
      (G2048_set_cell board row col value)
    )
    board
  )
)

;; ======================================================================
;; FUNÇÕES DE MOVIMENTO
;; ======================================================================

(defun G2048_merge_line (line / result merged i prev)
  (setq filtered '())
  (foreach cell line
    (if (/= cell 0)
      (setq filtered (cons cell filtered))
    )
  )
  (setq filtered (reverse filtered))
  
  (setq merged '())
  (setq i 0)
  (setq len (length filtered))
  
  (while (< i len)
    (if (and (< (1+ i) len) (= (nth i filtered) (nth (1+ i) filtered)))
      (progn
        (setq merged (cons (* 2 (nth i filtered)) merged))
        (setq G2048_score (+ G2048_score (* 2 (nth i filtered))))
        (setq i (+ i 2))
      )
      (progn
        (setq merged (cons (nth i filtered) merged))
        (setq i (1+ i))
      )
    )
  )
  
  (setq merged (reverse merged))
  
  (while (< (length merged) 4)
    (setq merged (cons 0 merged))
  )
  
  merged
)

(defun G2048_move_left (board / new_board)
  (setq new_board '())
  
  (foreach row board
    (setq new_board (cons (G2048_merge_line row) new_board))
  )
  
  (reverse new_board)
)

(defun G2048_move_right (board / new_board)
  (setq new_board '())
  
  (foreach row board
    (setq reversed_row (reverse row))
    (setq merged (G2048_merge_line reversed_row))
    (setq new_board (cons (reverse merged) new_board))
  )
  
  (reverse new_board)
)

(defun G2048_move_up (board / new_board col_idx)
  (setq new_board '((0 0 0 0) (0 0 0 0) (0 0 0 0) (0 0 0 0)))
  (setq col_idx 0)
  
  (while (< col_idx 4)
    (setq column '())
    (setq row_idx 0)
    (while (< row_idx 4)
      (setq column (cons (G2048_get_cell board row_idx col_idx) column))
      (setq row_idx (1+ row_idx))
    )
    (setq column (reverse column))
    
    (setq merged_column (G2048_merge_line column))
    
    (setq row_idx 0)
    (while (< row_idx 4)
      (setq new_board (G2048_set_cell new_board row_idx col_idx (nth row_idx merged_column)))
      (setq row_idx (1+ row_idx))
    )
    
    (setq col_idx (1+ col_idx))
  )
  
  new_board
)

(defun G2048_move_down (board / new_board col_idx)
  (setq new_board '((0 0 0 0) (0 0 0 0) (0 0 0 0) (0 0 0 0)))
  (setq col_idx 0)
  
  (while (< col_idx 4)
    (setq column '())
    (setq row_idx 3)
    (while (>= row_idx 0)
      (setq column (cons (G2048_get_cell board row_idx col_idx) column))
      (setq row_idx (1- row_idx))
    )
    
    (setq merged_column (G2048_merge_line column))
    
    (setq row_idx 3)
    (setq merged_idx 0)
    (while (>= row_idx 0)
      (setq new_board (G2048_set_cell new_board row_idx col_idx (nth merged_idx merged_column)))
      (setq row_idx (1- row_idx))
      (setq merged_idx (1+ merged_idx))
    )
    
    (setq col_idx (1+ col_idx))
  )
  
  new_board
)

(defun G2048_boards_equal (board1 board2 / equal row_idx col_idx)
  (setq equal T)
  (setq row_idx 0)
  
  (while (and equal (< row_idx 4))
    (setq col_idx 0)
    (while (and equal (< col_idx 4))
      (if (/= (G2048_get_cell board1 row_idx col_idx) (G2048_get_cell board2 row_idx col_idx))
        (setq equal nil)
      )
      (setq col_idx (1+ col_idx))
    )
    (setq row_idx (1+ row_idx))
  )
  
  equal
)

(defun G2048_check_game_over (board)
  (setq game_over T)
  
  (if (G2048_get_empty_cells board)
    (setq game_over nil)
    (progn
      (setq row_idx 0)
      (while (and game_over (< row_idx 4))
        (setq col_idx 0)
        (while (and game_over (< col_idx 4))
          (setq current (G2048_get_cell board row_idx col_idx))
          
          (if (and (< col_idx 3) (= current (G2048_get_cell board row_idx (1+ col_idx))))
            (setq game_over nil)
          )
          
          (if (and (< row_idx 3) (= current (G2048_get_cell board (1+ row_idx) col_idx)))
            (setq game_over nil)
          )
          
          (setq col_idx (1+ col_idx))
        )
        (setq row_idx (1+ row_idx))
      )
    )
  )
  
  game_over
)

(defun G2048_check_win (board)
  (setq won nil)
  
  (setq row_idx 0)
  (while (and (not won) (< row_idx 4))
    (setq col_idx 0)
    (while (and (not won) (< col_idx 4))
      (if (>= (G2048_get_cell board row_idx col_idx) 2048)
        (setq won T)
      )
      (setq col_idx (1+ col_idx))
    )
    (setq row_idx (1+ row_idx))
  )
  
  won
)

;; ======================================================================
;; FUNÇÕES DE DISPLAY
;; ======================================================================

(defun G2048_update_display ()
  ;; Atualiza todos os tiles com slides
  (setq row_idx 0)
  
  (foreach row G2048_board
    (setq col_idx 0)
    (foreach cell row
      (setq key (strcat "tile_" (itoa row_idx) "_" (itoa col_idx)))
      
      ;; Obtém informações do slide para este valor
      (setq slide_info (G2048_get_slide_info cell))
      (setq slide_name (car slide_info))
      (setq color_index (cadr slide_info))
      
      ;; Exibe o slide com a cor de fundo
      (G2048_ShowSld key slide_name color_index)
      
      (setq col_idx (1+ col_idx))
    )
    (setq row_idx (1+ row_idx))
  )
  
  ;; Atualiza pontuação
  (set_tile "score_display" (strcat "Pontuação: " (itoa G2048_score)))
  (set_tile "best_display" (strcat "Recorde: " (itoa G2048_best_score)))
  (set_tile "moves_display" (strcat "Movimentos: " (itoa G2048_moves)))
  
  ;; Atualiza status
  (cond
    (G2048_won
      (set_tile "status" "PARABÉNS! Você alcançou 2048! Continue jogando...")
    )
    (G2048_game_over
      (set_tile "status" "FIM DE JOGO! Não há mais movimentos possíveis.")
    )
    (T
      (set_tile "status" "Use os botões de setas para mover os números")
    )
  )
)

(defun G2048_init_board ()
  (setq G2048_board '(
    (0 0 0 0)
    (0 0 0 0)
    (0 0 0 0)
    (0 0 0 0)
  ))
  
  ;; Adiciona 2 tiles iniciais
  (setq G2048_board (G2048_add_random_tile G2048_board))
  (setq G2048_board (G2048_add_random_tile G2048_board))
  
  (setq G2048_previous_board nil)
  (setq G2048_score 0)
  (setq G2048_moves 0)
  (setq G2048_game_over nil)
  (setq G2048_won nil)
  
  ;; Atualiza melhor pontuação
  (if (> G2048_score G2048_best_score)
    (setq G2048_best_score G2048_score)
  )
)

(defun G2048_move (direction)
  (if (not G2048_game_over)
    (progn
      ;; Salva estado atual para desfazer
      (setq G2048_previous_board G2048_board)
      
      ;; Aplica movimento
      (cond
        ((= direction "left")
          (setq new_board (G2048_move_left G2048_board))
        )
        ((= direction "right")
          (setq new_board (G2048_move_right G2048_board))
        )
        ((= direction "up")
          (setq new_board (G2048_move_up G2048_board))
        )
        ((= direction "down")
          (setq new_board (G2048_move_down G2048_board))
        )
      )
      
      ;; Se o tabuleiro mudou, adiciona novo tile
      (if (not (G2048_boards_equal G2048_board new_board))
        (progn
          (setq G2048_board new_board)
          (setq G2048_board (G2048_add_random_tile G2048_board))
          (setq G2048_moves (1+ G2048_moves))
          
          ;; Atualiza melhor pontuação
          (if (> G2048_score G2048_best_score)
            (setq G2048_best_score G2048_score)
          )
          
          ;; Verifica condições de vitória/derrota
          (if (G2048_check_win G2048_board)
            (setq G2048_won T)
          )
          
          (if (G2048_check_game_over G2048_board)
            (setq G2048_game_over T)
          )
        )
        (set_tile "status" "Movimento inválido! Tente outra direção.")
      )
      
      (G2048_update_display)
    )
    (set_tile "status" "Fim de jogo! Clique em 'Novo Jogo' para recomeçar.")
  )
)

(defun G2048_undo ()
  (if G2048_previous_board
    (progn
      (setq G2048_board G2048_previous_board)
      (setq G2048_previous_board nil)
      (setq G2048_moves (1- G2048_moves))
      (G2048_update_display)
      (set_tile "status" "Movimento desfeito!")
    )
    (set_tile "status" "Não há movimentos para desfazer!")
  )
)

;; ======================================================================
;; FUNÇÃO PRINCIPAL
;; ======================================================================

(defun C:Game2048 ()
  (setq G2048_dcl_id (load_dialog "Game2048.dcl"))
  (if (not (new_dialog "game2048" G2048_dcl_id))
    (progn
      (princ "\nErro ao carregar a caixa de diálogo Game2048.dcl.")
      (unload_dialog G2048_dcl_id)
      (exit)
    )
  )
  
  ;; Configura ações dos botões
  (action_tile "btn_up" "(G2048_move \"up\")")
  (action_tile "btn_down" "(G2048_move \"down\")")
  (action_tile "btn_left" "(G2048_move \"left\")")
  (action_tile "btn_right" "(G2048_move \"right\")")
  (action_tile "btn_reset" "(G2048_init_board) (G2048_update_display)")
  (action_tile "btn_undo" "(G2048_undo)")
  (action_tile "sair" "(done_dialog 0)")
  (action_tile "help" "(Game2048_Help)")
  
  ;; Inicializa jogo
  (G2048_init_board)
  
  ;; Configura slides para elementos visuais
  (mode_tile "#arkz" 1)
  (G2048_ShowSld "#img_logo" "ArkZLogo" -2)
  (G2048_ShowSld "sep1" "Separato" -2)
  (G2048_ShowSld "sep2" "Separato" -2)
  
  ;; Configura botões de movimento com slides
  (G2048_setup_buttons)
  
  ;; Atualiza display do tabuleiro
  (G2048_update_display)
  
  (start_dialog)
  (unload_dialog G2048_dcl_id)
  (princ)
)

;;;===========================================================================
;;; FUNÇÃO DE AJUDA
;;;===========================================================================
;;;---------------------------------------------------------------------------
;;; StringWrap - Lee Mac, 2011 (modificado)
(defun StringWrap (str len / pos)
  (if (< len (strlen str))
    (cons
      (substr str 1
        (cond
          ((setq pos (vl-string-position 32 (substr str 1 len) nil t)))
          ((setq pos (1- len)) len)
        )
      )
      (StringWrap (substr str (+ 2 pos)) len)
    )
    (list str)
  )
)

;;;---------------------------------------------------------------------------
;;; Lê linhas de um arquivo de texto - Chat-GPT, 2024
(defun read-lines (filepath / file lines line)
  (setq lines nil)
  (if (and (setq filepath (findfile filepath))
           (setq file (open filepath "r")))
    (progn
      (while (setq line (read-line file))
        (setq lines (append lines (list line)))
      )
      (close file)
    )
    (progn
      (alert (strcat "Arquivo não encontrado: " filepath))
      nil
    )
  )
  lines
)

;;;---------------------------------------------------------------------------
;;; Processa texto para exibição em list_box
(defun process-text-for-display (lines max-width)
  (if lines
    (apply 'append 
      (mapcar '(lambda (line) (StringWrap line max-width)) lines)
    )
    (list "Nenhuma informação disponível.")
  )
)

;;;---------------------------------------------------------------------------
;;; Função Game2048_Help
(defun Game2048_Help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Game2048.txt
  (if (not (findfile "Game2048.txt"))
    (progn
      (alert "O arquivo Game2048.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Game2048.dcl"))
               (new_dialog "Game2048_Help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Game2048.txt"))
            (progn
              (setq display-text (process-text-for-display lines 60))
              (start_list "lstAbout")
              (foreach line display-text
                (add_list line)
              )
              (end_list)
            )
            ;; Se não conseguir ler o arquivo (mesmo existindo)
            (progn
              (start_list "lstAbout")
              (foreach line '("Erro ao ler o arquivo de ajuda." 
                             "Verifique se o arquivo não está corrompido."
                             ""
                             "Contate o suporte técnico.")
                (add_list line)
              )
              (end_list)
            )
          )
          
          ;; Exibe logo
          (G2048_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Game2048 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Game2048.dcl.")
      )
    )
  )
  (princ)
)
;;;


(princ "\nGame2048 com botões visuais carregado. Digite Game2048 para iniciar.")
(princ)
