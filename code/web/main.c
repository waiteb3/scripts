#include "fmt.h"
#include "web.h"

int main() {
    Println("listening on http://localhost:9000");
    Bind(".");

    return 0;
}
