CREATE TABLE IF NOT EXISTS transacoes (
    id BIGSERIAL PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    data_transacao DATE NOT NULL
);