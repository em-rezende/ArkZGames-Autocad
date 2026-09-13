;; ====================================================================
;; VARIÁVEIS GLOBAIS E FUNÇÕES AUXILIARES
;; ====================================================================

(setq DM_dcl_id nil)
(setq DM_board_size 8) 
(setq DM_board nil)
(setq DM_player_turn 'JOGADOR) 
(setq DM_selected_piece nil) 
(setq DM_search_depth 2) ; Valor padrão para o slider
(setq *DM_force_capture_enabled* "1") ; Toggle para forçar captura (1 = Ativado)
(setq computer_best_move nil) 
(setq *DM_ai_pause_enabled* "0") 
(setq *DM_game_history* nil) ; Histórico de movimentos
(setq *DM_save_file* "Checkers_save.txt") ; Nome do arquivo de estado
(setq *DM_notation_file* "Checkers_notation.txt") ; Nome do arquivo de notação

;; Funções Auxiliares: DM_drop, DM_take, DM_update_cell, DM_get_piece
(defun DM_drop (n lst)
  (if (<= n 0) lst (if (cdr lst) (DM_drop (1- n) (cdr lst)) nil))
)

(defun DM_take (n lst)
  (if (or (<= n 0) (null lst)) nil (cons (car lst) (DM_take (1- n) (cdr lst))))
)

(defun DM_update_cell (DM_board row col value)
  (append (DM_take row DM_board) 
          (list (append (DM_take col (nth row DM_board)) 
                        (list value) 
                        (DM_drop (1+ col) (nth row DM_board)))) 
          (DM_drop (1+ row) DM_board))
)

(defun DM_get_piece (row col / piece)
    (if (and (>= row 0) (< row DM_board_size) (>= col 0) (< col DM_board_size))
        (setq piece (nth col (nth row DM_board)))
        (setq piece nil)
    )
    piece
)

(defun DM_is_opponent (piece current_player)
    (if (and piece (or (eq current_player 'JOGADOR) (eq current_player 'K_JOGADOR)))
        (or (eq piece 'COMPUTADOR) (eq piece 'K_COMPUTADOR))
        (or (eq piece 'JOGADOR) (eq piece 'K_JOGADOR))
    )
)

(defun DM_ShowSld (tile slide color / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  (fill_image 0 0 x y color) 
  (slide_image 0 0 x y
    (strcat "Checkers_8x8" " (" (vl-filename-base slide) ")")
  )
  (end_image)
  (princ)
)

;; ====================================================================
;; FUNÇÕES DE CONTROLE DE CONFIGURAÇÃO
;; ====================================================================

(defun DM_set_search_depth (value)
    (setq DM_search_depth (atoi value))
    (princ (strcat "\nProfundidade de Busca (IA) definida para: " (itoa DM_search_depth)))
)

(defun DM_set_force_capture (value)
    (setq *DM_force_capture_enabled* value)
    (princ (strcat "\nForçar Captura: " (if (= value "1") "Ativado" "Desativado")))
)


;; Função corrigida para usar mode_tile
(defun DM_set_pause_state (value)
    (setq *DM_ai_pause_enabled* value)

    ;; CORREÇÃO: Usa mode_tile (0 = Habilitar / 1 = Desabilitar)
    ;; O botão deve ser HABILITADO (0) se o valor for "1" (pausa ligada).
    (mode_tile "continue_button" (if (= value "1") 0 1)) 

    (princ (strcat "\nModo de Pausa da IA: " (if (= value "1") "Ativado (Passo-a-passo)" "Desativado (Automático)")))
)
;; ====================================================================
;; SALVAMENTO E NOTAÇÃO (FUNÇÃO CORRIGIDA)
;; ====================================================================

;; Mapeia coordenadas (row col) para a notação padrão 1-32
(defun DM_coord_to_draughts (row col / table cell_number)
  (setq table 
    '("" "4" "" "3" "" "2" "" "1"  ; Row 0
      "8" "" "7" "" "6" "" "5" ""  ; Row 1
      "" "12" "" "11" "" "10" "" "9"  ; Row 2
      "16" "" "15" "" "14" "" "13" "" ; Row 3
      "" "20" "" "19" "" "18" "" "17" ; Row 4
      "24" "" "23" "" "22" "" "21" "" ; Row 5
      "" "28" "" "27" "" "26" "" "25" ; Row 6
      "32" "" "31" "" "30" "" "29" "" ; Row 7
    )
  )
  (setq cell_number (nth (+ (* row 8) col) table))
  (if (or (not cell_number) (= cell_number ""))
      ""
      cell_number
  )
)

;; Grava o movimento no histórico
(defun DM_record_move (from_coord to_coord is_capture)
    (setq move_str (strcat 
        (DM_coord_to_draughts (car from_coord) (cadr from_coord))
        (if is_capture "x" "-") ; x para captura, - para movimento simples
        (DM_coord_to_draughts (car to_coord) (cadr to_coord))
    ))
    (setq *DM_game_history* (append *DM_game_history* (list move_str)))
    (princ (strcat "\nMovimento Gravado: " move_str))
)

;; Salva o estado atual do jogo (CORREÇÃO FINAL: Injeção do Apóstrofo)
(defun DM_save_game_state ()
    (setq fp (open *DM_save_file* "w"))
    (if fp
        (progn
            ;; CORREÇÃO 1: Serializa o DM_board (Lista de listas com símbolos)
            (princ "(setq DM_board '" fp)
            (princ (vl-princ-to-string DM_board) fp)
            (princ ")\n" fp)

            ;; CORREÇÃO 2: Serializa o DM_player_turn (Símbolo)
            (princ "(setq DM_player_turn '" fp)
            (princ (vl-princ-to-string DM_player_turn) fp)
            (princ ")\n" fp)
            
            ;; CORREÇÃO 3: Serializa DM_selected_piece (Lista ou nil)
            (princ "(setq DM_selected_piece '" fp)
            (princ (vl-princ-to-string DM_selected_piece) fp)
            (princ ")\n" fp)

            ;; CORREÇÃO 4: Serializa *DM_game_history* (Lista de strings)
            (princ "(setq *DM_game_history* '" fp)
            (princ (vl-princ-to-string *DM_game_history*) fp)
            (princ ")\n" fp)
            
            ;; O resto das variáveis simples
            (princ (strcat "(setq DM_search_depth " (itoa DM_search_depth) ")\n") fp)
            (princ (strcat "(setq *DM_force_capture_enabled* \"" *DM_force_capture_enabled* "\")\n") fp)
            (princ (strcat "(setq *DM_ai_pause_enabled* \"" *DM_ai_pause_enabled* "\")\n") fp)
            
            ;; Definições de tiles
            (princ (strcat "(set_tile \"turn_status\" \"" (get_tile "turn_status") "\")\n") fp)
            (princ (strcat "(set_tile \"search_depth_slider\" \"" (itoa DM_search_depth) "\")\n") fp)
            (princ (strcat "(set_tile \"slider_value_label\" \"" (itoa DM_search_depth) "\")\n") fp)
            (princ (strcat "(set_tile \"force_capture_toggle\" \"" *DM_force_capture_enabled* "\")\n") fp)
            (princ (strcat "(set_tile \"pause_toggle\" \"" *DM_ai_pause_enabled* "\")\n") fp)
            (princ (strcat "(princ \"\\nJogo salvo com sucesso em " *DM_save_file* ".\")\n") fp)
            (close fp)
            (alert (strcat "Jogo salvo com sucesso em " (findfile *DM_save_file*) "."))
        )
        (alert (strcat "ERRO: Não foi possível abrir o arquivo de salvamento: " *DM_save_file*))
    )
    (princ)
)

;; Carrega o estado do jogo salvo
(defun DM_load_game_state ()
    (if (findfile *DM_save_file*)
        (progn
            (load *DM_save_file*) ; Executa o arquivo que redefine as variáveis.
            (set_tile "continue_button" "0") 
            (DM_update_board_display)
            (alert (strcat "Jogo carregado com sucesso de " (findfile *DM_save_file*) "."))
        )
        (alert (strcat "ERRO: Arquivo de salvamento não encontrado: " *DM_save_file*))
    )
    (princ)
)

;; Salva a notação de todos os movimentos
;; Salva a notação do jogo em um arquivo de texto (CORRIGIDO)
(defun DM_save_game_notation ()
    (setq fp (open *DM_notation_file* "w"))
    (if fp
        (progn
            (foreach move *DM_game_history*
                ;; CORREÇÃO: Força o elemento a ser uma string antes de escrever
                (princ (strcat (vl-princ-to-string move) "\n") fp) 
            )
            (close fp)
            (princ (strcat "\nNotação salva em " *DM_notation_file* "."))
            (alert (strcat "Notação salva com sucesso em " (findfile *DM_notation_file*) "."))
        )
        (alert (strcat "ERRO: Não foi possível abrir o arquivo de notação: " *DM_notation_file*))
    )
    (princ)
)

;; ====================================================================
;; INICIALIZAÇÃO E EXIBIÇÃO
;; ====================================================================

(defun DM_initialize_game_damas ()
  (setq DM_board nil)
  (setq DM_player_turn 'JOGADOR) 
  (setq DM_selected_piece nil)
  (setq computer_best_move nil)
  (setq *DM_game_history* nil) ; Zera o histórico ao iniciar um novo jogo
  
  (setq rows DM_board_size)
  (setq cols DM_board_size)
  (setq new_board nil)

  (setq row 0)
  (while (< row rows)
    (setq current_row nil)
    (setq col 0)
    (while (< col cols)
      (setq piece nil)
      
      (if (= (rem (+ row col) 2) 1) 
          (cond
              ((< row 3) (setq piece 'COMPUTADOR)) 
              ((> row 4) (setq piece 'JOGADOR))    
          )
      )
      
      (setq current_row (append current_row (list piece)))
      (setq col (1+ col))
    )
    (setq new_board (append new_board (list current_row)))
    (setq row (1+ row))
  )
  (setq DM_board new_board) 
  
  (set_tile "turn_status" (strcat (vl-princ-to-string DM_player_turn) " (Sua Vez)"))
  (action_tile "turn_status" "") 
  
  ;; Define valores iniciais nos controles ao iniciar o jogo
  (set_tile "pause_toggle" *DM_ai_pause_enabled*)
  (set_tile "search_depth_slider" (itoa DM_search_depth))
  (set_tile "slider_value_label" (itoa DM_search_depth))
  (set_tile "force_capture_toggle" *DM_force_capture_enabled*)
  (mode_tile "continue_button" (if (= *DM_ai_pause_enabled* "1") 0 1))
  
  (DM_update_board_display)
  (princ)
)

(defun DM_update_board_display ()
  (setq rows DM_board_size)
  (setq cols DM_board_size)
  (setq row 0)
  (while (< row rows)
    (setq col 0)
    (while (< col cols)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq val (nth col (nth row DM_board)))
      
      ;; CORREÇÃO: Altera a cor das casas para Cinza Escuro (251) e  Cinza Claro (254)
      (setq color_index (if (= (rem (+ row col) 2) 1) 251 254)) 
      
      (setq is_current_piece_selected 
          (and DM_selected_piece 
               (= row (car DM_selected_piece)) 
               (= col (cadr DM_selected_piece))
          )
      )
      
      (setq slide-name
        (cond
          ((and is_current_piece_selected (eq val 'JOGADOR)) "JOGADORS") 
          ((and is_current_piece_selected (eq val 'COMPUTADOR)) "COMPUTADORS") 
          ((and is_current_piece_selected (eq val 'K_JOGADOR)) "K_JOGADORS") 
          ((and is_current_piece_selected (eq val 'K_COMPUTADOR)) "K_COMPUTADORS") 
          
          ((eq val 'JOGADOR) "JOGADOR")    
          ((eq val 'COMPUTADOR) "COMPUTADOR")    
          ((eq val 'K_JOGADOR) "K_JOGADOR")   
          ((eq val 'K_COMPUTADOR) "K_COMPUTADOR")  
          (T "BLANK")           
        )
      )
      
      (DM_ShowSld key slide-name color_index) 
      (action_tile key (strcat "(DM_cell_clicked \"" key "\")")) 
      
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  (princ)
)
;; ====================================================================
;; LÓGICA CENTRAL DO JOGO: MOVIMENTO E CAPTURA
;; ====================================================================

(defun DM_check_capture (DM_board from_coord / from_row from_col piece current_player is_king captures dr dc to_row to_col capt_row capt_col)
    (setq from_row (car from_coord))
    (setq from_col (cadr from_coord))
    (setq piece (DM_get_piece from_row from_col))
    
    (setq current_player 
        (cond
            ((or (eq piece 'JOGADOR) (eq piece 'K_JOGADOR)) 'JOGADOR)
            ((or (eq piece 'COMPUTADOR) (eq piece 'K_COMPUTADOR)) 'COMPUTADOR)
            (T nil)
        )
    )
    (setq is_king (or (eq piece 'K_JOGADOR) (eq piece 'K_COMPUTADOR)))
    (setq captures nil)

    (foreach dr '(-2 2)
        (foreach dc '(-2 2)
            (setq to_row (+ from_row dr))
            (setq to_col (+ from_col dc))
            (setq capt_row (fix (/ (+ from_row to_row) 2))) 
            (setq capt_col (fix (/ (+ from_col to_col) 2)))
            
            (if (and (>= to_row 0) (< to_row DM_board_size) (>= to_col 0) (< to_col DM_board_size)) 
                (if (null (DM_get_piece to_row to_col)) 
                    (if (DM_is_opponent (DM_get_piece capt_row capt_col) current_player) 
                        (progn
                            (if (or is_king
                                    (and (eq piece 'JOGADOR) (< dr 0)) 
                                    (and (eq piece 'COMPUTADOR) (> dr 0))) 
                                (setq captures (cons (list (list from_row from_col) (list to_row to_col) (list capt_row capt_col)) captures))
                            )
                        )
                    )
                )
            )
        )
    )
    captures
)

(defun DM_get_all_valid_moves (DM_board current_player / all_captures all_moves row col piece captures moves dr dc next_row next_col d_rows is_king player_king)
    (setq all_captures nil)
    (setq all_moves nil)
    (setq player_king (read (strcat "K_" (vl-princ-to-string current_player))))

    (setq row 0)
    (while (< row DM_board_size)
        (setq col 0)
        (while (< col cols)
            (setq piece (DM_get_piece row col))
            (if (or (eq piece current_player) (eq piece player_king))
                (progn
                    (setq captures (DM_check_capture DM_board (list row col)))
                    (if captures 
                        (setq all_captures (append all_captures captures))
                    )
                    
                    (setq is_king (eq piece player_king))
                    (setq d_rows (if is_king '(-1 1) (if (eq current_player 'JOGADOR) '(-1) '(1))))
                    
                    (foreach dr d_rows
                        (foreach dc '(-1 1)
                            (setq next_row (+ row dr))
                            (setq next_col (+ col dc))
                            
                            (if (and (>= next_row 0) (< next_row DM_board_size) (>= next_col 0) (< next_col DM_board_size))
                                (if (null (DM_get_piece next_row next_col))
                                    (setq all_moves (cons (list (list row col) (list next_row next_col)) all_moves))
                                )
                            )
                        )
                    )
                )
            )
            (setq col (1+ col))
        )
        (setq row (1+ row))
    )
    
    (if (and (not (null all_captures)) (= *DM_force_capture_enabled* "1"))
        all_captures 
        (append all_captures all_moves)
    )
)

(defun DM_is_valid_move (from_coord to_coord / current_piece current_player valid_moves found)
    (setq current_piece (DM_get_piece (car from_coord) (cadr from_coord)))
    
    (setq current_player 
        (cond
            ((or (eq current_piece 'JOGADOR) (eq current_piece 'K_JOGADOR)) 'JOGADOR)
            ((or (eq current_piece 'COMPUTADOR) (eq current_piece 'K_COMPUTADOR)) 'COMPUTADOR)
            (T nil)
        )
    )
    
    (setq valid_moves (DM_get_all_valid_moves DM_board current_player))
    
    (setq found nil)
    (foreach move valid_moves
        (if (and 
                (= (car (car move)) (car from_coord))
                (= (cadr (car move)) (cadr from_coord))
                (= (car (cadr move)) (car to_coord))
                (= (cadr (cadr move)) (cadr to_coord))
            )
            (setq found T)
        )
    )
    found
)
;; ====================================================================
;; LÓGICA CENTRAL DO JOGO: MOVIMENTO E CAPTURA (CORRIGIDA E ROBUSTA)
;; ====================================================================

(defun DM_make_move (from_coord to_coord / from_row from_col to_row to_col piece king_line is_capture capt_row capt_col next_player)
    
    ;; 1. Extração de Coordenadas (segura)
    (setq from_row (car from_coord))
    (setq from_col (cadr from_coord))
    (setq to_row (car to_coord))
    (setq to_col (cadr to_coord)) 
    
    (setq piece (DM_get_piece from_row from_col))
    (setq is_capture (= (abs (- to_row from_row)) 2))
    
    (setq DM_board (DM_update_cell DM_board from_row from_col nil))
    
    (if is_capture
        (progn
            (setq capt_row (fix (/ (+ from_row to_row) 2)))
            (setq capt_col (fix (/ (+ from_col to_col) 2)))
            (setq DM_board (DM_update_cell DM_board capt_row capt_col nil))
        )
    )
    
    (setq king_line (if (or (eq piece 'JOGADOR) (eq piece 'K_JOGADOR)) 0 7)) 
    (if (and (eq to_row king_line) (or (eq piece 'JOGADOR) (eq piece 'COMPUTADOR)))
        (setq piece (read (strcat "K_" (vl-princ-to-string piece))))
    )

    (setq DM_board (DM_update_cell DM_board to_row to_col piece))
    
    ;; Grava o movimento antes de mudar o turno
    (DM_record_move from_coord to_coord is_capture) 
    
    (setq next_player (if (eq DM_player_turn 'JOGADOR) 'COMPUTADOR 'JOGADOR))
    (setq DM_player_turn next_player)
    
    (set_tile "turn_status" (strcat (vl-princ-to-string next_player) " (Sua Vez)"))
    (action_tile "turn_status" "")
    (setq DM_selected_piece nil)
    
    (DM_update_board_display)
    
    (princ)
)

;; ====================================================================
;; INTELIGÊNCIA ARTIFICIAL (DM_minimax)
;; ====================================================================

(defun DM_make_move_simulated (DM_board from_coord to_coord current_player / new_board from_row from_col to_row to_col piece is_capture capt_row capt_col king_line)
    (setq new_board DM_board)
    (setq from_row (car from_coord))
    (setq from_col (cadr from_coord))
    (setq to_row (car to_coord))
    (setq to_col (cadr to_coord))
    (setq piece (DM_get_piece from_row from_col))
    (setq is_capture (= (abs (- to_row from_row)) 2))
    
    (setq new_board (DM_update_cell new_board from_row from_col nil))
    
    (if is_capture
        (progn
            (setq capt_row (fix (/ (+ from_row to_row) 2)))
            (setq capt_col (fix (/ (+ from_col to_col) 2)))
            (setq new_board (DM_update_cell new_board capt_row capt_col nil))
        )
    )
    
    (setq king_line (if (eq current_player 'JOGADOR) 0 7))
    (if (and (eq to_row king_line) (or (eq piece 'JOGADOR) (eq piece 'COMPUTADOR)))
        (setq piece (read (strcat "K_" (vl-princ-to-string piece))))
    )

    (setq new_board (DM_update_cell new_board to_row to_col piece))
    new_board 
)

(defun DM_evaluate_board (DM_board / score row col piece)
    (setq score 0)
    (setq row 0)
    (while (< row DM_board_size)
        (setq col 0)
        (while (< col DM_board_size)
            (setq piece (nth col (nth row DM_board)))
            (cond
                ((eq piece 'COMPUTADOR) (setq score (+ score 10 (- 7 row)))) 
                ((eq piece 'K_COMPUTADOR) (setq score (+ score 30)))         
                ((eq piece 'JOGADOR) (setq score (- score 10 row)))         
                ((eq piece 'K_JOGADOR) (setq score (- score 30)))          
            )
            (setq col (1+ col))
        )
        (setq row (1+ row))
    )
    score
)

(defun DM_minimax (current_board depth is_maximizing_player / current_player all_moves max_eval min_eval move_tuple new_board DM_eval)
    (setq current_player (if is_maximizing_player 'COMPUTADOR 'JOGADOR)) 
    (setq all_moves (DM_get_all_valid_moves current_board current_player))
    
    (cond
        ((= depth 0) (DM_evaluate_board current_board))
        ((null all_moves) (DM_evaluate_board current_board))

        (is_maximizing_player
            (setq max_eval -100000)
            (foreach move_tuple all_moves
                (setq new_board (DM_make_move_simulated current_board (car move_tuple) (cadr move_tuple) current_player))
                (setq DM_eval (DM_minimax new_board (1- depth) nil))
                (if (> DM_eval max_eval) (setq max_eval DM_eval))
            )
            max_eval
        )
        (T 
            (setq min_eval 100000)
            (foreach move_tuple all_moves
                (setq new_board (DM_make_move_simulated current_board (car move_tuple) (cadr move_tuple) current_player))
                (setq DM_eval (DM_minimax new_board (1- depth) t))
                (if (< DM_eval min_eval) (setq min_eval DM_eval))
            )
            min_eval
        )
    )
)

;; ====================================================================
;; INTELIGÊNCIA ARTIFICIAL (SELEÇÃO DE MOVIMENTO)
;; ====================================================================

(defun DM_computer_select_move ()
    (setq all_moves (DM_get_all_valid_moves DM_board 'COMPUTADOR)) 
    
    ;; 1. VERIFICAÇÃO DE FIM DE JOGO (IA SEM MOVIMENTOS)
    (if (null all_moves)
        (DM_end_game_dialog "JOGADOR")
        
        (progn
            
            ;; 2. EXIBE MENSAGEM INICIAL DE CÁLCULO
            (set_tile "turn_status" "COMPUTADOR (IA Calculando...)")
            (princ "\nIA está pensando... Por favor, aguarde.")
            (redraw) 
            
            (setq best_move nil)
            (setq max_eval -100000)
            
            ;; INÍCIO DO CÁLCULO DM_minimax (Síncrono)
            (foreach move_tuple all_moves
                (setq from_coord (car move_tuple))
                (setq to_coord (cadr move_tuple))
                
                (setq new_board (DM_make_move_simulated DM_board from_coord to_coord 'COMPUTADOR))
                (setq DM_eval (DM_minimax new_board (1- DM_search_depth) nil))
                
                ;; VERIFICAÇÃO DE SEGURANÇA
                (if (and (numberp DM_eval) (> DM_eval max_eval)) 
                    (progn
                        (setq max_eval DM_eval)
                        (setq best_move move_tuple)
                    )
                )
            )
            ;; FIM DO CÁLCULO
            
            ;; 3. Após o cálculo, executa ou notifica o erro
            (if best_move
                (progn
                    (princ (strcat "\nIA escolheu o movimento de: " (vl-princ-to-string (car best_move)) " para " (vl-princ-to-string (cadr best_move))))
                    
                    (setq computer_best_move best_move) 
                    
                    (if (= *DM_ai_pause_enabled* "1") 
                        (progn
                            (setq DM_selected_piece (car best_move)) 
                            (DM_update_board_display)
                            
                            (mode_tile "continue_button" 0) 
                            (set_tile "turn_status" "COMPUTADOR (Pronto! Clique em Prosseguir)")
                        )
                        (DM_computer_execute_move) 
                    )
                )
                (progn
                    ;; Se best_move for NIL, a IA não encontrou uma jogada válida
                    (set_tile "turn_status" "ERRO: IA não pôde calcular o movimento. Jogo Parado.")
                )
            )
        )
    )
    (princ)
)
;; ====================================================================
;; EXECUTA O MELHOR MOVIMENTO ENCONTRADO PELA IA
;; ====================================================================

(defun DM_computer_execute_move ()
    (if computer_best_move
        (progn
            (setq from_coord (car computer_best_move))
            (setq to_coord (cadr computer_best_move))
            
            (princ (strcat "\nMovimento da IA: " (vl-princ-to-string from_coord) " -> " (vl-princ-to-string to_coord)))
            
            ;; 1. EXECUTA O MOVIMENTO
            (DM_make_move from_coord to_coord) 
            
            ;; 2. LIMPA O ESTADO DA IA
            (setq DM_selected_piece nil)
            (setq computer_best_move nil)
            
            ;; 3. DESABILITA O BOTÃO PROSSEGUIR
            (mode_tile "continue_button" 1)
            
            ;; 4. VERIFICAÇÃO DE FIM DE JOGO: JOGADOR SEM MOVIMENTOS = COMPUTADOR VENCE
            (setq player_moves (DM_get_all_valid_moves DM_board 'JOGADOR))
            
            (if (null player_moves)
                (DM_end_game_dialog "COMPUTADOR") ; Se JOGADOR não tem movimentos, COMPUTADOR VENCE
                (progn
                    ;; 5. PASSA O TURNO PARA O JOGADOR
                    (setq DM_player_turn 'JOGADOR)
                    (set_tile "turn_status" "JOGADOR (Sua Vez)")
                    (DM_update_board_display)
                )
            )
        )
        (princ "\nERRO: Nenhuma jogada da IA para executar.")
    )
    (princ)
)
;; ====================================================================
;; CONTROLE DE JOGADA (EVENTOS DE CLIQUE)
;; ====================================================================

(defun DM_cell_clicked (key / row_str col_str row col piece sel_row sel_col)
  
  (if (and (eq DM_player_turn 'JOGADOR) (= (get_tile "continue_button") "1"))
    (princ "\nClique ignorado (turno do computador ou jogo pausado).") 
    (progn 
      (setq row_str (substr key 6 1))
      (setq col_str (substr key 8 1))
      (setq row (atoi row_str))
      (setq col (atoi col_str))
      (setq piece (DM_get_piece row col))
      
      (if (null DM_selected_piece)
        (progn
          ;; Caso 2: Selecionar peça
          (if (and piece (or (eq piece 'JOGADOR) (eq piece 'K_JOGADOR))) 
              (progn
                (setq DM_selected_piece (list row col))
                (princ (strcat "\nPeça selecionada: (" (itoa row) ", " (itoa col) ")"))
                (DM_update_board_display) 
              )
              (princ "\nNão é sua peça ou a casa está vazia.")
          )
        )
        
        (progn
          (setq sel_row (car DM_selected_piece))
          (setq sel_col (cadr DM_selected_piece))
          
          (if (and (= row sel_row) (= col sel_col))
              (progn
                ;; Caso 3: Cancelar seleção
                (setq DM_selected_piece nil)
                (princ "\nSeleção cancelada.")
                (DM_update_board_display) 
              )
              
              (progn
                ;; Caso 4: Tentar mover
                (if (DM_is_valid_move DM_selected_piece (list row col))
                    (progn
                        (DM_make_move DM_selected_piece (list row col))
                        
                        (if (eq DM_player_turn 'COMPUTADOR) 
                            (DM_computer_select_move) 
                        )
                    )
                    
                    (princ (strcat "\nMovimento inválido. Peça selecionada: (" (itoa sel_row) ", " (itoa sel_col) "). Tente outro destino ou re-selecione a peça."))
                )
              )
          )
        )
      )
    )
  ) 
  (princ) ; CRÍTICO: Garante o retorno NIL para o DCL
)
;; ====================================================================
;; FUNÇÃO DE FIM DE JOGO (VERSÃO SEGURA E ROBUSTA)
;; ====================================================================

(defun DM_end_game_dialog (winner / alert_msg)
    
    (set_tile "turn_status" (strcat "FIM DE JOGO: " winner " VENCEU! Use o botão SALVAR NOTAÇÃO abaixo."))
    (princ (strcat "\nFIM DE JOGO: " winner " VENCEU! A notação pode ser salva agora."))
    
    ;; Bloqueia novos movimentos na interface, mantendo o DCL aberto
    (setq DM_player_turn 'NIL) 
    (setq DM_selected_piece nil)
    (DM_update_board_display) 
    
    ;; Desabilita o botão "Prosseguir"
    (mode_tile "continue_button" 1)
    
    (princ) ; Retorna o valor seguro (NIL) para o DCL
)

;; ====================================================================
;; COMANDO PRINCIPAL
;; ====================================================================

(defun C:CHECKERS_8X8 ()
  (setq DM_dcl_id (load_dialog "Checkers_8x8.dcl"))
  
  (if (not (new_dialog "checkers_dialog" DM_dcl_id))
    (exit)
  )
  (mode_tile "#arkz" 1)

  (DM_ShowSld "#img_logo" "ArkZLogo" -2)
  (DM_ShowSld "sep1"     "Separato"  -2)
  (DM_ShowSld "sep2"     "Separato"  -2)
  (DM_ShowSld "sep3"     "Separato"  -2) 
  
  (action_tile "pause_toggle" "(DM_set_pause_state $value)") 
  (action_tile "search_depth_slider" "(DM_set_search_depth $value) (set_tile \"slider_value_label\" $value)")
  (action_tile "force_capture_toggle" "(DM_set_force_capture $value)") 
  (action_tile "continue_button" "(DM_computer_execute_move)") 

  ;; Ações para salvar/carregar
  (action_tile "save_state_button" "(DM_save_game_state)")
  (action_tile "load_state_button" "(DM_load_game_state)")
  (action_tile "save_notation_button" "(DM_save_game_notation)")
  
  (DM_initialize_game_damas)
  
  (action_tile "restart" "(DM_initialize_game_damas)")
  (action_tile "cancel" "(done_dialog)")
  (action_tile "help" "(Checkers_8x8_help)")
  
  (start_dialog)
  (unload_dialog DM_dcl_id)
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
;;; Função Checkers_8x8_Help
(defun Checkers_8x8_help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Checkers_8x8.txt
  (if (not (findfile "Checkers_8x8.txt"))
    (progn
      (alert "O arquivo Checkers_8x8.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Checkers_8x8.dcl"))
               (new_dialog "Checkers_8x8_help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Checkers_8x8.txt"))
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
          (DM_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Checkers_8x8 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Checkers_8x8.dcl.")
      )
    )
  )
  (princ)
)
;;;

(princ "\nCheckers_8X8 carregado. Digite Checkers_8X8 para iniciar o jogo.")
(princ)