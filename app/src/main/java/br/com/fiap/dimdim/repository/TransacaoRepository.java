package br.com.fiap.dimdim.repository;

import br.com.fiap.dimdim.model.Transacao;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TransacaoRepository extends JpaRepository<Transacao, Long> {
}