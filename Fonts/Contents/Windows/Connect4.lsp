;; ====================================================================
;; CONNECT4.LSP - JOGO CONECTA 4 (OU N) EM AUTOLISP PURO
;; Versão Final: IA com Heurística Dinâmica e Checagem de Gravidade
;; ====================================================================

;; --------------------------------------------------------------------
;; VARIÁVEIS GLOBAIS
;; --------------------------------------------------------------------
(setq C4_dcl_id nil)
(setq C4_board_rows 6) ; Número de linhas do tabuleiro (0 a 5)
(setq C4_board_cols 7) ; Número de colunas do tabuleiro (0 a 6)
(setq C4_board nil)    ; Representação da matriz do tabuleiro
(setq C4_player_turn 'JOGADOR) ; Jogador atual. 'JOGADOR (Disco 1) ou 'COMPUTADOR (Disco 2)
(setq C4_required_connections 4) ; Conexões necessárias para vencer (definido pelo slider)
(setq C4_search_depth 4) ; Profundidade de busca padrão para a IA (pode ser ajustada no slider)
(setq C4_computer_best_move nil) ; Armazena o melhor movimento encontrado pela IA
(setq *ai_pause_enabled* "0") ; Se '1', a IA pausa após calcular o movimento
(setq *game_history* nil) ; Histórico de movimentos

;; --------------------------------------------------------------------
;; FUNÇÕES AUXILIARES DE LISTA (C4_drop, C4_take, Update)
;; --------------------------------------------------------------------

;; Remove os N primeiros elementos de uma lista
(defun C4_drop (n lst)
  (if (<= n 0) lst (if (cdr lst) (C4_drop (1- n) (cdr lst)) nil))
)

;; Retorna os N primeiros elementos de uma lista
(defun C4_take (n lst)
  (if (or (<= n 0) (null lst)) nil (cons (car lst) (C4_take (1- n) (cdr lst))))
)

;; Atualiza o valor de uma célula específica no tabuleiro (matriz de listas)
(defun C4_update_cell (C4_board row col value)
  (append (C4_take row C4_board) 
          (list (append (C4_take col (nth row C4_board)) 
                        (list value) 
                        (C4_drop (1+ col) (nth row C4_board)))) 
          (C4_drop (1+ row) C4_board))
)

;; Obtém a peça em uma coordenada (row, col)
(defun C4_get_piece (row col / piece)
    (if (and (>= row 0) (< row C4_board_rows) (>= col 0) (< col C4_board_cols))
        (setq piece (nth col (nth row C4_board)))
        (setq piece nil)
    )
    piece
)

;; Exibe a imagem (Slide) na DCL
(defun C4_ShowSld (tile slide color / x y)
  (setq x (dimx_tile tile))
  (setq y (dimy_tile tile))
  (start_image tile)
  (fill_image 0 0 x y color) 
  (slide_image 0 0 x y
    (strcat "Connect4" " (" (vl-filename-base slide) ")")
  )
  (end_image)
  (princ)
)

;; --------------------------------------------------------------------
;; FUNÇÕES DE CONTROLE DE CONFIGURAÇÃO
;; --------------------------------------------------------------------

(defun C4_set_search_depth (value)
    (setq C4_search_depth (atoi value))
    (princ (strcat "\nProfundidade de Busca (IA) definida para: " (itoa C4_search_depth)))
)

(defun C4_set_required_connections (value) 
    (setq C4_required_connections (atoi value))
    (princ (strcat "\nConexões necessárias definidas para: " (itoa C4_required_connections)))
)

(defun C4_set_pause_state (value)
    (setq *ai_pause_enabled* value)
    (mode_tile "continue_button" (if (= value "1") 0 1)) 
    (princ (strcat "\nModo de Pausa da IA: " (if (= value "1") "Ativado" "Desativado")))
)

;; --------------------------------------------------------------------
;; INICIALIZAÇÃO E EXIBIÇÃO
;; --------------------------------------------------------------------

(defun C4_initialize_game ( / row col current_row)
  (setq C4_board nil)
  (setq C4_player_turn 'JOGADOR) 
  (setq C4_computer_best_move nil)
  (setq *game_history* nil) 
  
  ;; Cria o tabuleiro vazio
  (setq row 0)
  (while (< row C4_board_rows)
    (setq current_row nil)
    (setq col 0)
    (while (< col C4_board_cols)
      (setq current_row (append current_row (list nil)))
      (setq col (1+ col))
    )
    (setq C4_board (append C4_board (list current_row)))
    (setq row (1+ row))
  )
  
  ;; Atualiza a interface DCL
  (set_tile "turn_status" (strcat (vl-princ-to-string C4_player_turn) " (Sua Vez)"))
  (action_tile "turn_status" "") 
  (set_tile "pause_toggle" *ai_pause_enabled*)
  (set_tile "search_depth_slider" (itoa C4_search_depth))
  (set_tile "slider_value_label" (itoa C4_search_depth))
  (set_tile "connect_slider" (itoa C4_required_connections)) 
  (set_tile "connect_value_label" (itoa C4_required_connections))
  (mode_tile "continue_button" (if (= *ai_pause_enabled* "1") 0 1))
  
  (C4_update_board_display)
  (redraw) 
  (princ)
)

;; Desenha o tabuleiro na DCL usando Slides
(defun C4_update_board_display ()
  (setq row 0)
  (while (< row C4_board_rows)
    (setq col 0)
    (while (< col C4_board_cols)
      (setq key (strcat "cell_" (itoa row) "_" (itoa col)))
      (setq val (nth col (nth row C4_board)))
      
      (setq color_index 8) 
      
      (setq slide-name
        (cond
          ((eq val 'JOGADOR) "JOGADOR")    
          ((eq val 'COMPUTADOR) "COMPUTADOR") 
          (T "BLANK")           
        )
      )
      
      (C4_ShowSld key slide-name color_index) 
      (action_tile key (strcat "(C4_column_clicked \"" (itoa col) "\")")) 
      
      (setq col (1+ col))
    )
    (setq row (1+ row))
  )
  (princ)
)

;; --------------------------------------------------------------------
;; LÓGICA CENTRAL DO JOGO: MOVIMENTO
;; --------------------------------------------------------------------

;; Encontra a primeira linha vazia de baixo para cima na coluna
(defun C4_find_next_available_row (col / row found_row)
    (setq row (1- C4_board_rows)) 
    (setq found_row nil)
    
    (while (and (>= row 0) (null found_row))
        (if (null (C4_get_piece row col))
            (setq found_row row) 
        )
        (if (null found_row) 
            (setq row (1- row))
        )
    )
    found_row 
)

;; Checa se uma peça específica venceu (N-em-linha)
(defun C4_check_win (C4_board piece / row col dr dc count win_found dirs current_dir)
    (setq win_found nil)
    ;; Direções de checagem: Horizontal (0 1), Vertical (1 0), Diagonal (\) (1 1), Diagonal (/) (1 -1)
    (setq dirs '((0 1) (1 0) (1 1) (1 -1))) 
    
    (setq row 0)
    (while (and (< row C4_board_rows) (null win_found))
        (setq col 0)
        (while (and (< col C4_board_cols) (null win_found))
            (if (eq (C4_get_piece row col) piece)
                (progn
                    (setq current_dir dirs)
                    (while (and current_dir (null win_found)) 
                        (setq dir (car current_dir))
                        (setq current_dir (cdr current_dir))
                        
                        (setq dr (car dir))
                        (setq dc (cadr dir))
                        (setq count 1)
                        (setq r (+ row dr))
                        (setq c (+ col dc))
                        
                        ;; Conta as peças consecutivas na direção
                        (while (and (>= r 0) (< r C4_board_rows) 
                                    (>= c 0) (< c C4_board_cols) 
                                    (eq (C4_get_piece r c) piece))
                            (setq count (1+ count))
                            (setq r (+ r dr))
                            (setq c (+ c dc))
                        )
                        
                        ;; Se atingiu o número de conexões necessário, venceu
                        (if (>= count C4_required_connections) 
                            (setq win_found T) 
                        )
                    )
                )
            )
            (setq col (1+ col))
        )
        (setq row (1+ row))
    )
    win_found 
)

;; Executa o movimento principal no tabuleiro real
(defun C4_make_move (col / row next_player success)
    (setq row (C4_find_next_available_row col))
    (setq success nil)
    
    (if row 
        (progn 
            (setq C4_board (C4_update_cell C4_board row col C4_player_turn))
            
            ;; (Salva histórico, atualiza display...)
            (C4_update_board_display)
            (redraw) 
            
            (if (C4_check_win C4_board C4_player_turn)
                (C4_end_game_dialog C4_player_turn)
                (progn
                    (setq next_player (if (eq C4_player_turn 'JOGADOR) 'COMPUTADOR 'JOGADOR))
                    (setq C4_player_turn next_player)
                    (set_tile "turn_status" (strcat (vl-princ-to-string C4_player_turn) " (Sua Vez)"))
                    
                    (if (null (C4_get_all_valid_moves C4_board))
                        (C4_end_game_dialog 'EMPATE)
                    )
                )
            )
            (setq success T) 
        )
    )
    success 
)

;; Retorna uma lista de todos os movimentos válidos (row, col)
(defun C4_get_all_valid_moves (C4_board / all_moves col row)
    (setq all_moves nil)
    (setq col 0)
    (while (< col C4_board_cols)
        (setq row (C4_find_next_available_row col))
        (if row
            (setq all_moves (cons (list row col) all_moves))
        )
        (setq col (1+ col))
    )
    all_moves
)

;; --------------------------------------------------------------------
;; INTELIGÊNCIA ARTIFICIAL (C4_minimax COM HEURÍSTICA CORRIGIDA)
;; --------------------------------------------------------------------

;; Faz um movimento em uma cópia simulada do tabuleiro
(defun C4_make_move_simulated (C4_board row col current_player / new_board)
    (setq new_board C4_board)
    (setq new_board (C4_update_cell new_board row col current_player))
    new_board 
)

;; **FUNÇÃO CRÍTICA DE GRAVIDADE:**
;; Verifica se o slot (row, col) onde a peça seria jogada é válido, 
;; i.e., se a peça abaixo (row+1) existe, ou se é a linha de baixo (row=5).
(defun C4_is_valid_threat_position (C4_board row col)
    (or 
        (= row (1- C4_board_rows)) ; É a linha de baixo (sempre válido)
        (C4_get_piece (1+ row) col) ; OU a peça abaixo já está ocupada
    )
)

;; FUNÇÃO CORRIGIDA: Pontua ameaças dinamicamente e com checagem de jogabilidade.
(defun C4_get_score_for_player (C4_board piece / row col dr dc count dirs current_dir score primary_threat secondary_threat r_start c_start)
    (setq score 0)
    (setq dirs '((0 1) (1 0) (1 1) (1 -1))) ; H, V, D1, D2
    
    ;; Define o tamanho das ameaças baseado no C4_required_connections
    (setq primary_threat (1- C4_required_connections)) ; Ex: 3-em-linha para Connect-4
    (setq secondary_threat (if (> primary_threat 1) (1- primary_threat) nil)) ; Ex: 2-em-linha para Connect-4
    
    (setq row 0)
    (while (< row C4_board_rows)
        (setq col 0)
        (while (< col C4_board_cols)
            
            (setq current_dir dirs)
            (while current_dir 
                (setq dir (car current_dir))
                (setq current_dir (cdr current_dir))
                
                (setq dr (car dir))
                (setq dc (cadr dir))
                (setq count 0)
                (setq empty_slot nil) ; O slot vazio que completaria a linha
                
                ;; Percorre a linha na direção (dr, dc)
                (setq r_curr row)
                (setq c_curr col)
                (while (and (>= r_curr 0) (< r_curr C4_board_rows) 
                            (>= c_curr 0) (< c_curr C4_board_cols) 
                            (<= count primary_threat)
                            )
                    (setq current_piece (C4_get_piece r_curr c_curr))
                    
                    (cond
                        ;; Se for a peça do jogador que estamos avaliando
                        ((eq current_piece piece)
                            (setq count (1+ count))
                        )
                        ;; Se for um espaço vazio (e for o primeiro)
                        ((and (null current_piece) (null empty_slot))
                            (setq empty_slot (list r_curr c_curr))
                            (setq count (1+ count)) ; Conta o slot vazio como parte do potencial
                        )
                        ;; Se for peça do oponente ou já tiver um slot vazio (linha quebrada)
                        (T
                            (setq count 0)
                            (setq empty_slot nil)
                            (setq r_curr 100) ; Quebra o loop para essa direção (otimização)
                        )
                    )

                    ;; **AVALIAÇÃO CRÍTICA DA AMEAÇA PRIMÁRIA (BLOQUEIO)**
                    (if (and (= (1- count) primary_threat) ; Temos N-1 peças
                             empty_slot                     ; Há um slot vazio para o N-ésimo
                             (C4_is_valid_threat_position C4_board (car empty_slot) (cadr empty_slot))) ; E o slot é jogável
                        (setq score (+ score 100000000)) ; PESO EXTREMO (100 Milhões) - Bloqueio de vitória
                    )

                    ;; AVALIAÇÃO DA AMEAÇA SECUNDÁRIA
                    (if (and secondary_threat 
                             (= (1- count) secondary_threat) 
                             empty_slot 
                             (C4_is_valid_threat_position C4_board (car empty_slot) (cadr empty_slot)))
                        (setq score (+ score 1000000))  ; PESO ALTO (1 Milhão)
                    )

                    ;; Move para o próximo ponto na direção
                    (setq r_curr (+ r_curr dr))
                    (setq c_curr (+ c_curr dc))
                )
            )
            (setq col (1+ col))
        )
        (setq row (1+ row))
    )
    score
)

;; **HEURÍSTICA PRINCIPAL:** Avalia a qualidade do tabuleiro
(defun C4_evaluate_board (C4_board / score comp_score player_score)
    (setq score 0)
    
    ;; 1. Checagem de Vitória/Derrota Imediata (PRIORIDADE MÁXIMA - 1 Trilhão)
    ;; Isso garante que a IA sempre escolha a vitória mais rápida ou evite a derrota mais rápida.
    (if (C4_check_win C4_board 'COMPUTADOR) (setq score (+ score 1000000000000))) 
    (if (C4_check_win C4_board 'JOGADOR) (setq score (- score 1000000000000)))  
    
    ;; 2. Pontuação por ameaças (ESTRATÉGIA)
    (setq comp_score (C4_get_score_for_player C4_board 'COMPUTADOR))
    (setq player_score (C4_get_score_for_player C4_board 'JOGADOR))
    
    ;; Subtrair o score do jogador força a IA a MINIMIZAR as ameaças do oponente (BLOQUEAR)
    (setq score (+ score comp_score))   ; Adiciona a pontuação da IA
    (setq score (- score player_score))  ; Subtrai a pontuação do Jogador (PRIORIZA BLOQUEIO)
    
    ;; 3. Controle Central (BÔNUS POSICIONAL)
    (setq center_col (fix (/ (1- C4_board_cols) 2)))
    (setq row 0)
    (while (< row C4_board_rows)
        (if (eq (C4_get_piece row center_col) 'COMPUTADOR) (setq score (+ score 3)))
        (if (eq (C4_get_piece row center_col) 'JOGADOR) (setq score (- score 3)))
        (setq row (1+ row))
    )
    
    score
)

;; **ALGORITMO C4_minimax COM PODA ALPHA-BETA**
(defun C4_minimax (current_board depth is_maximizing_player alpha beta / current_player all_moves max_eval min_eval move_coord new_board C4_eval temp_moves)
    (setq current_player (if is_maximizing_player 'COMPUTADOR 'JOGADOR)) 
    (setq all_moves (C4_get_all_valid_moves current_board))
    
    ;; Constante de Infinito/Gama Alpha-Beta (Usada para inicialização)
    (setq max_alpha_beta 10000000000000) 
    
    ;; Condições de Parada
    (cond
        ((= depth 0) (C4_evaluate_board current_board)) ; Atingiu a profundidade máxima
        ((null all_moves) (C4_evaluate_board current_board)) ; Sem movimentos (Empate)
        ((C4_check_win current_board (if is_maximizing_player 'JOGADOR 'COMPUTADOR)) (C4_evaluate_board current_board)) ; Vitória do oponente (nó de derrota)
        ((C4_check_win current_board (if is_maximizing_player 'COMPUTADOR 'JOGADOR)) (C4_evaluate_board current_board)) ; Vitória da IA (nó de vitória)

        ;; MAXIMIZADOR (COMPUTADOR)
        (is_maximizing_player
            (setq max_eval (* -1 max_alpha_beta)) ; Inicializa com valor negativo infinito
            (setq temp_moves all_moves)
            (while temp_moves 
                (setq move_coord (car temp_moves))
                (setq temp_moves (cdr temp_moves)) 
                
                (setq new_board (C4_make_move_simulated current_board (car move_coord) (cadr move_coord) current_player))
                (setq C4_eval (C4_minimax new_board (1- depth) nil alpha beta)) ; Chama o MINIMIZADOR
                
                (setq max_eval (max max_eval C4_eval))
                (setq alpha (max alpha max_eval))
                
                (if (>= alpha beta) ; PODA: Se alpha for maior ou igual a beta, ignora o resto dos movimentos
                    (setq temp_moves nil) 
                )
            )
            max_eval 
        )
        
        ;; MINIMIZADOR (JOGADOR)
        (T 
            (setq min_eval max_alpha_beta) ; Inicializa com valor positivo infinito
            (setq temp_moves all_moves)
            (while temp_moves 
                (setq move_coord (car temp_moves))
                (setq temp_moves (cdr temp_moves))
                
                (setq new_board (C4_make_move_simulated current_board (car move_coord) (cadr move_coord) current_player))
                (setq C4_eval (C4_minimax new_board (1- depth) t alpha beta)) ; Chama o MAXIMIZADOR
                
                (setq min_eval (min min_eval C4_eval))
                (setq beta (min beta min_eval))
                
                (if (<= alpha beta) ; PODA: Se beta for menor ou igual a alpha, ignora o resto dos movimentos
                    (setq temp_moves nil) 
                )
            )
            min_eval 
        )
    )
)

;; Função que inicia o processo de cálculo da IA e seleciona o melhor movimento
(defun C4_computer_select_move ()
    (setq all_moves (C4_get_all_valid_moves C4_board)) 
    
    (if (null all_moves)
        (C4_end_game_dialog 'EMPATE)
        (progn
            (set_tile "turn_status" "COMPUTADOR (IA Calculando...)")
            (redraw) 
            
            (setq best_move nil) 
            (setq max_eval -10000000000000) ; Inicializa com valor negativo extremo
            
            ;; Itera sobre todos os movimentos válidos para encontrar o melhor
            (foreach move_coord all_moves 
                (setq row (car move_coord))
                (setq col (cadr move_coord))
                
                (setq new_board (C4_make_move_simulated C4_board row col 'COMPUTADOR))
                ;; O primeiro nó chama o minimizador, que é o turno do jogador (nil)
                (setq C4_eval (C4_minimax new_board (1- C4_search_depth) nil -10000000000000 10000000000000)) 
                
                (if (> C4_eval max_eval) 
                    (progn
                        (setq max_eval C4_eval)
                        (setq best_move move_coord)
                    )
                )
            )
            
            (if best_move
                (progn
                    (princ (strcat "\nIA escolheu a coluna: " (vl-princ-to-string (cadr best_move))))
                    (setq C4_computer_best_move best_move) 
                    
                    ;; Se a pausa estiver ativada, espera o clique no botão "Prosseguir"
                    (if (= *ai_pause_enabled* "1") 
                        (progn
                            (mode_tile "continue_button" 0) 
                            (set_tile "turn_status" "COMPUTADOR (Pronto! Clique em Prosseguir)")
                        )
                        (C4_computer_execute_move) ; Senão, executa o movimento imediatamente
                    )
                )
                (set_tile "turn_status" "ERRO: IA não pôde calcular o movimento. Jogo Parado.")
            )
        )
    )
    (princ)
)

;; Executa o movimento escolhido pela IA
(defun C4_computer_execute_move ()
    (if C4_computer_best_move
        (progn
            (setq col (cadr C4_computer_best_move))
            (princ (strcat "\nMovimento da IA na coluna: " (vl-princ-to-string col)))
            
            (C4_make_move col) 
            
            (setq C4_computer_best_move nil)
            (mode_tile "continue_button" 1)
        )
        (princ "\nERRO: Nenhuma jogada da IA para executar.")
    )
    (princ)
)

;; --------------------------------------------------------------------
;; CONTROLE DE JOGADA E FIM DE JOGO (Interface)
;; --------------------------------------------------------------------

;; Ação disparada ao clicar em uma célula do tabuleiro (coluna)
(defun C4_column_clicked (col_str / col)
  
  (setq col (atoi col_str))
  
  (if (and (eq C4_player_turn 'JOGADOR) (= (get_tile "continue_button") "1"))
    (princ "\nClique ignorado (turno do computador ou jogo pausado).") 
    (progn 
      (if (C4_make_move col) 
        (if (eq C4_player_turn 'COMPUTADOR) 
            (C4_computer_select_move) 
        )
      )
    )
  ) 
  (princ) 
)

;; Exibe a mensagem de fim de jogo
(defun C4_end_game_dialog (winner / alert_msg)
    
    (setq alert_msg 
        (cond
            ((eq winner 'JOGADOR) "FIM DE JOGO: JOGADOR VENCEU!")
            ((eq winner 'COMPUTADOR) "FIM DE JOGO: COMPUTADOR VENCEU!")
            (T "FIM DE JOGO: EMPATE!")
        )
    )
    (set_tile "turn_status" alert_msg) 
    (princ (strcat "\n" alert_msg))
    
    (setq C4_player_turn 'NIL) ; Bloqueia movimentos
    (mode_tile "continue_button" 1)
    
    (princ) 
)

;; --------------------------------------------------------------------
;; COMANDO PRINCIPAL
;; --------------------------------------------------------------------

;; Comando principal para iniciar o jogo (digitar Connect4 no AutoCAD)
(defun C:Connect4 (/ C4_dcl_id)
  (setq C4_dcl_id (load_dialog "Connect4.dcl"))
  
  (if (not (new_dialog "connect4_dialog" C4_dcl_id))
    (exit)
  )
  
  ;; Configuração da interface e ações
  (mode_tile "#arkz" 1)
  (C4_ShowSld "#img_logo" "ArkZLogo" -2)
  (C4_ShowSld "sep1"  "Separato" -2)
  (C4_ShowSld "sep2"  "Separato" -2)
  (C4_ShowSld "sep3"  "Separato" -2) 
  
  ;; Ações para sliders e toggles de configuração
  (action_tile "pause_toggle" "(C4_set_pause_state $value)") 
  (action_tile "search_depth_slider" "(C4_set_search_depth $value) (set_tile \"slider_value_label\" $value)")
  (action_tile "connect_slider" "(C4_set_required_connections $value) (set_tile \"connect_value_label\" $value)") 
  
  ;; Botão "Prosseguir" (para quando a pausa da IA está ativada)
  (action_tile "continue_button" "(C4_computer_execute_move)") 

  (C4_initialize_game)
  
  (action_tile "restart" "(C4_initialize_game)")
  (action_tile "cancel" "(done_dialog)")
  (action_tile "help" "(Connect4_help)")
  
  (start_dialog)
  (unload_dialog C4_dcl_id)
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
;;; Função Connect4_help
(defun Connect4_help (/ dcl_id lines display-text)
  ;; Verifica existência do arquivo Connect4.txt
  (if (not (findfile "Connect4.txt"))
    (progn
      (alert "O arquivo Connect4.txt não foi encontrado.\n\nO programa de ajuda não será apresentado.")
      (princ)  ;; Retorna silenciosamente sem abrir o DCL
    )
    (progn
      ;; Arquivo existe, prossegue com a abertura do diálogo
      (if (and (setq dcl_id (load_dialog "Connect4.dcl"))
               (new_dialog "Connect4_help" dcl_id))
        (progn
          ;; Carrega e exibe o texto do arquivo de ajuda
          (if (setq lines (read-lines "Connect4.txt"))
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
          (C4_ShowSld "#img_logo" "ArkZLogo" -2)
          
          ;; Preenche dados do registro
          (setq reg1 "ARK-Z ARQUITETURA LTDA - Ezequiel M Rezende")
          (setq reg2 "Aplicativos para o Autocad 2013 - 2026")
          (setq reg3 "Connect4 - License GNU GPLv3 © 2026 Ezequiel M Rezende")
          (setq reg4 "https://em-rezende.github.io/")
          (setq regdat (strcat reg1 "\n" reg2 "\n" reg3 "\n" reg4))
          (set_tile "reg_dat" regdat)
		  
          ;; Define ação do botão OK
          (action_tile "btnOK" "(done_dialog 1)")
          
          ;; Inicia o diálogo
          (start_dialog)
          (unload_dialog dcl_id)
        )
        (alert "Erro ao carregar diálogo de ajuda.\nVerifique o arquivo Connect4.dcl.")
      )
    )
  )
  (princ)
)
;;;

(princ "\nConnect4 carregado. Digite Connect4 para iniciar o jogo.")
(princ)
