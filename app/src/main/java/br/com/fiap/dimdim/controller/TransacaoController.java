package br.com.fiap.dimdim.controller;

import br.com.fiap.dimdim.model.Transacao;
import br.com.fiap.dimdim.repository.TransacaoRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transacoes")
public class TransacaoController {

    private final TransacaoRepository repository;

    public TransacaoController(TransacaoRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<Transacao> listar() {
        return repository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Transacao> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Transacao> criar(@Valid @RequestBody Transacao transacao) {
        transacao.setId(null);
        return ResponseEntity.ok(repository.save(transacao));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Transacao> atualizar(
            @PathVariable Long id,
            @Valid @RequestBody Transacao transacao) {

        return repository.findById(id)
                .map(existente -> {
                    existente.setDescricao(transacao.getDescricao());
                    existente.setValor(transacao.getValor());
                    existente.setTipo(transacao.getTipo());
                    existente.setDataTransacao(transacao.getDataTransacao());

                    return ResponseEntity.ok(repository.save(existente));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {

        if (!repository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}