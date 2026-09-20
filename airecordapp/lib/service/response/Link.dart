/**
 * 支付链接
 */
class Link {
  String method;
  String href;

  Link({
    required this.method,
    required this.href,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      method: json['method'],
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'href': href,
      };
}
