-- 1. Listar todos os agricultores e as sementes que eles receberam.
SELECT
    a.nome AS nome_agricultor,
    s.nome_semente,
    d.quantidade_entregue,
    d.data_entrega
FROM agricultores a
JOIN distribuicoes d ON a.id_agricultores = d.agricultores_id_agricultores
JOIN semente s ON d.semente_id_semente = s.id_semente
ORDER BY a.nome;

-- 2. Mostrar quais técnicos são responsáveis por quais agricultores e em que data a distribuição foi feita.
SELECT
    t.nome AS nome_tecnico,
    a.nome AS nome_agricultor,
    d.data_entrega,
    t.area_responsavel
FROM tecnicos t
JOIN distribuicoes d ON t.distribuicoes_id_distribuicao = d.id_distribuicao
JOIN agricultores a ON d.agricultores_id_agricultores = a.id_agricultores
ORDER BY t.nome;

-- 3. Relatório de cultivo: listar agricultores, sementes e a fase de crescimento atual.
SELECT
    a.nome AS nome_agricultor,
    s.nome_semente,
    c.fase_crescimento,
    c.data_registro
FROM cultivos c
JOIN distribuicoes d ON c.distribuicoes_id_distribuicao = d.id_distribuicao
JOIN agricultores a ON d.agricultores_id_agricultores = a.id_agricultores
JOIN semente s ON d.semente_id_semente = s.id_semente
WHERE c.fase_crescimento <> 'colheita'
ORDER BY c.data_registro DESC;

-- 4. Consultar a quantidade total de sementes distribuídas por tipo de cultura.
SELECT
    s.tipo_cultura,
    SUM(d.quantidade_entregue) AS total_distribuido_kg
FROM distribuicoes d
JOIN semente s ON d.semente_id_semente = s.id_semente
GROUP BY s.tipo_cultura
ORDER BY total_distribuido_kg DESC;

-- 5. Listar as sementes cuja validade expira no próximo ano (2026).
SELECT
    s.nome_semente,
    s.lote,
    s.data_validade,
    s.id_semente
FROM semente s
JOIN distribuicoes d on s.id_semente = d.semente_id_semente
WHERE YEAR(data_validade) = 2026
ORDER BY data_validade ASC;

-- 6. Verificar o histórico de movimentação de um lote de semente específico.
SELECT
    s.nome_semente,
    r.origem,
    r.destino,
    r.data_movimentacao,
    r.tipo_movimentacao
FROM rastreabilidade r
JOIN semente s ON r.semente_id_semente = s.id_semente
WHERE s.lote = 'L005';

-- 7. Mostrar agricultores que receberam mais de 150 kg de sementes em uma única entrega.
SELECT
    a.nome,
    a.telefone,
    s.nome_semente,
    d.quantidade_entregue
FROM agricultores a
JOIN distribuicoes d ON a.id_agricultores = d.agricultores_id_agricultores
JOIN semente s ON d.semente_id_semente = s.id_semente
WHERE d.quantidade_entregue > 150
ORDER BY d.quantidade_entregue DESC;

-- 8. Listar todos os cultivos que estão na fase de "colheita".
SELECT
    a.nome AS agricultor,
    s.nome_semente AS semente,
    c.descricao
FROM cultivos c
JOIN distribuicoes d ON c.distribuicoes_id_distribuicao = d.id_distribuicao
JOIN agricultores a ON d.agricultores_id_agricultores = a.id_agricultores
JOIN semente s ON d.semente_id_semente = s.id_semente
WHERE c.fase_crescimento = 'colheita';

-- 9. Obter o nome dos usuários que realizaram sincronizações com erro.
SELECT
    u.nome_usuario,
    s.tabela_afetada,
    s.data_sync,
    s.detalhes
FROM usuarios u
JOIN sincronizacoes s ON u.id_usuario = s.usuarios_id_usuario
WHERE s.status = 'erro';

-- 10. Listar as últimas 10 ações registradas no histórico do sistema.
SELECT
    hr.data_acao,
    u.nome_usuario,
    hr.acao,
    hr.tabela,
    hr.id_registro
FROM historico_registros hr
JOIN usuarios u ON hr.usuarios_id_usuario = u.id_usuario
ORDER BY hr.data_acao DESC
LIMIT 10;

-- 11. Encontrar agricultores que ainda não tiveram um registro de cultivo associado.
SELECT
    a.nome,
    a.telefone
FROM agricultores a
LEFT JOIN distribuicoes d ON a.id_agricultores = d.agricultores_id_agricultores
LEFT JOIN cultivos c ON d.id_distribuicao = c.distribuicoes_id_distribuicao
WHERE c.idcultivos IS NULL;

-- 12. Quantidade de sementes distribuídas por cada técnico.
SELECT
    t.nome AS nome_tecnico,
    COUNT(d.id_distribuicao) AS numero_distribuicoes,
    SUM(d.quantidade_entregue) AS total_kg_entregue
FROM tecnicos t
JOIN distribuicoes d ON t.distribuicoes_id_distribuicao = d.id_distribuicao
GROUP BY t.nome
ORDER BY total_kg_entregue DESC;

-- 13. Sementes com quantidade em estoque abaixo de 700 kg.
SELECT	
    s.nome_semente,
    s.tipo_cultura,
    s.quat_disponivel,
    (select r.semente_id_semente 
    from rastreabilidade r 
    where r.semente_id_semente = s.id_semente
    LIMIT 1) as `id rastreio`,
    (select r.observacoes 
    from rastreabilidade r
    where r.semente_id_semente = s.id_semente
    limit 1) as `estado semente`
FROM semente s
left join distribuicoes d 
on s.id_semente = d.semente_id_semente 
WHERE s.id_semente < 15;
-- 14. Agricultores e a data da última entrega de sementes recebida.
SELECT
    a.nome,
    MAX(d.data_entrega) AS ultima_entrega
FROM agricultores a
JOIN distribuicoes d ON a.id_agricultores = d.agricultores_id_agricultores
GROUP BY a.nome
ORDER BY ultima_entrega DESC;

-- 15. Listar distribuições que não foram sincronizadas (status_sync = 0).
SELECT
    d.id_distribuicao,
    a.nome AS agricultor,
    s.nome_semente,
    d.data_entrega
FROM distribuicoes d
JOIN agricultores a ON d.agricultores_id_agricultores = a.id_agricultores
JOIN semente s ON d.semente_id_semente = s.id_semente
WHERE d.status_sync = 0;

-- 16. Consultar quais sementes foram originadas do "IPA Recife".
SELECT
	s.id_semente,
    s.nome_semente,
    s.lote,
    s.quat_disponivel,
    d.semente_id_semente as id_distribuição,
	d.responsavel_entrega
FROM semente s
left join distribuicoes d
	on d.semente_id_semente = s.id_semente
left join 
	(select u.tipo_usuario,
	nome_usuario
	from usuarios u
	where u.tipo_usuario = 'tecnico') u on d.responsavel_entrega = u.tipo_usuario 
		WHERE origem = 'IPA Recife';

-- 17. Relatório de atividades por usuário (quantas ações cada um realizou).
SELECT
    u.nome_usuario,
    u.tipo_usuario,
    COUNT(hr.idhistorico_registros) AS total_acoes
FROM usuarios u
LEFT JOIN historico_registros hr ON u.id_usuario = hr.usuarios_id_usuario
GROUP BY u.nome_usuario, u.tipo_usuario
ORDER BY total_acoes DESC;

-- 18. Listar agricultores que receberam sementes de "Milho".
SELECT
    a.id_agricultores,
    a.nome,
    a.endereco,
    d.agricultores_id_agricultores
FROM agricultores a
LEFT JOIN distribuicoes d 
    ON d.agricultores_id_agricultores = a.id_agricultores 
WHERE a.id_agricultores IN (
    SELECT d.agricultores_id_agricultores
    FROM distribuicoes d
    JOIN semente s ON d.semente_id_semente = s.id_semente
    WHERE s.tipo_cultura = 'Milho'
);
-- 19. Total de sementes distribuídas por mês/ano.
SELECT
    YEAR(data_entrega) AS ano,
    MONTH(data_entrega) AS mes,
    SUM(quantidade_entregue) AS total_kg,
    d.semente_id_semente
FROM distribuicoes d
JOIN semente s on d.semente_id_semente = s.id_semente
GROUP BY YEAR(data_entrega), MONTH(data_entrega), d.semente_id_semente
ORDER BY ano, mes, d.semente_id_semente;

-- 20. Técnicos que atuam na "Zona da Mata" e os agricultores que eles atenderam.
SELECT
    t.nome AS tecnico,
    a.nome AS agricultor,
    s.nome_semente
FROM tecnicos t
JOIN distribuicoes d ON t.distribuicoes_id_distribuicao = d.id_distribuicao
JOIN agricultores a ON d.agricultores_id_agricultores = a.id_agricultores
JOIN semente s ON d.semente_id_semente = s.id_semente
WHERE t.area_responsavel = 'Zona da Mata';