# Optional: a clean environment with the pinned toolchain.
#   docker build -t ches27-185 . && docker run --rm ches27-185 [smoke|table7|ppprt|baseline|all]
FROM golang:1.26.8-bookworm
RUN curl -fsSL -o /usr/local/bin/solc \
      https://github.com/ethereum/solidity/releases/download/v0.8.24/solc-static-linux \
 && chmod +x /usr/local/bin/solc
WORKDIR /artifact
COPY . .
ENTRYPOINT ["scripts/run.sh"]
CMD ["all"]
