import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/presentation/no_results_display.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/detail/application/repo_detail_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RepoDetailPage extends ConsumerStatefulWidget {
  const RepoDetailPage({Key? key, required this.repo}) : super(key: key);

  final GithubRepo repo;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RepoDetailPageState();
}

class _RepoDetailPageState extends ConsumerState<RepoDetailPage> {
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(repoDetailNotifierProvider.notifier)
          .getRepoDetail(widget.repo.fullName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repoDetailNotifierProvider);
    ref.listen<RepoDetailState>(
      repoDetailNotifierProvider,
      (previous, next) {
        next.maybeWhen(
          loadSuccess: (repoDetail, _) {
            if (!repoDetail.isFresh && !hasAlreadyShownNoConnectionToast) {
              hasAlreadyShownNoConnectionToast = true;
              showNoConnectionToast(
                "You are not online. Some information may be outdated.",
                context,
              );
            }
          },
          orElse: () {},
        );
      },
    );

    return WillPopScope(
      onWillPop: () async {
        if (state.hasStarredStatusChanged) {
          ref
              .read(starredReposNotifierProvider.notifier)
              .getFirstStarredReposPage();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Hero(
                tag: widget.repo.fullName,
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    widget.repo.owner.avatarUrlSmall,
                  ),
                  backgroundColor: Colors.transparent,
                  radius: 16,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child:
                    Text(widget.repo.fullName, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          actions: [
            state.maybeMap(
              loadSuccess: (state) {
                return IconButton(
                  disabledColor: Theme.of(context).iconTheme.color,
                  onPressed: !state.repoDetail.isFresh
                      ? null
                      : () {
                          ref
                              .read(repoDetailNotifierProvider.notifier)
                              .switchStarredStatus(
                                state.repoDetail.entity!.fullName,
                              );
                        },
                  icon: Icon(
                    !state.repoDetail.isFresh
                        ? MdiIcons.starRemoveOutline
                        : state.repoDetail.entity?.starred == true
                            ? Icons.star
                            : Icons.star_border_outlined,
                  ),
                );
              },
              orElse: () {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade400,
                  highlightColor: Colors.grey.shade600,
                  child: IconButton(
                    disabledColor: Theme.of(context).iconTheme.color,
                    onPressed: null,
                    icon: const Icon(Icons.star),
                  ),
                );
              },
            )
          ],
        ),
        body: state.map(
          initial: (value) => Container(),
          loadInProgress: (value) => const CircularProgressIndicator(),
          loadSuccess: (value) {
            if (value.repoDetail.entity == null) {
              return const NoResultsDisplay(
                message:
                    'These are approximately all the details we could find.',
              );
            } else {
              return WebView(
                navigationDelegate: (navigation) {
                  if (navigation.url.startsWith('data:')) {
                    return NavigationDecision.navigate;
                  } else {
                    launchUrlString(navigation.url,
                        mode: LaunchMode.inAppWebView);
                    return NavigationDecision.prevent;
                  }
                },
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: Uri.dataFromString(
                  '''
                  <!DOCTYPE html>
                  <html lang="en">
                  <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <meta http-equiv="X-UA-Compatible" content="ie=edge">
                    <title>HTML 5 Boilerplate</title>
                    <link rel="stylesheet" href="style.css">
                  </head>
                  <body>
                    ${value.repoDetail.entity!.html}
                  </body>

                  </html>
                  $css''',
                  mimeType: 'text/html',
                  encoding: utf8,
                ).toString(),
              );
            }
          },
          loadFailure: (value) => Center(
            child: Text(value.failure.toString()),
          ),
        ),
      ),
    );
  }

  final css = """
    <style>
      @media (prefers-color-scheme:dark){.markdown-body{color-scheme:dark;--color-prettylights-syntax-comment:#8b949e;--color-prettylights-syntax-constant:#79c0ff;--color-prettylights-syntax-entity:#d2a8ff;--color-prettylights-syntax-storage-modifier-import:#c9d1d9;--color-prettylights-syntax-entity-tag:#7ee787;--color-prettylights-syntax-keyword:#ff7b72;--color-prettylights-syntax-string:#a5d6ff;--color-prettylights-syntax-variable:#ffa657;--color-prettylights-syntax-brackethighlighter-unmatched:#f85149;--color-prettylights-syntax-invalid-illegal-text:#f0f6fc;--color-prettylights-syntax-invalid-illegal-bg:#8e1519;--color-prettylights-syntax-carriage-return-text:#f0f6fc;--color-prettylights-syntax-carriage-return-bg:#b62324;--color-prettylights-syntax-string-regexp:#7ee787;--color-prettylights-syntax-markup-list:#f2cc60;--color-prettylights-syntax-markup-heading:#1f6feb;--color-prettylights-syntax-markup-italic:#c9d1d9;--color-prettylights-syntax-markup-bold:#c9d1d9;--color-prettylights-syntax-markup-deleted-text:#ffdcd7;--color-prettylights-syntax-markup-deleted-bg:#67060c;--color-prettylights-syntax-markup-inserted-text:#aff5b4;--color-prettylights-syntax-markup-inserted-bg:#033a16;--color-prettylights-syntax-markup-changed-text:#ffdfb6;--color-prettylights-syntax-markup-changed-bg:#5a1e02;--color-prettylights-syntax-markup-ignored-text:#c9d1d9;--color-prettylights-syntax-markup-ignored-bg:#1158c7;--color-prettylights-syntax-meta-diff-range:#d2a8ff;--color-prettylights-syntax-brackethighlighter-angle:#8b949e;--color-prettylights-syntax-sublimelinter-gutter-mark:#484f58;--color-prettylights-syntax-constant-other-reference-link:#a5d6ff;--color-fg-default:#c9d1d9;--color-fg-muted:#8b949e;--color-fg-subtle:#484f58;--color-canvas-default:#0d1117;--color-canvas-subtle:#161b22;--color-border-default:#30363d;--color-border-muted:#21262d;--color-neutral-muted:rgba(110,118,129,0.4);--color-accent-fg:#58a6ff;--color-accent-emphasis:#1f6feb;--color-attention-subtle:rgba(187,128,9,0.15);--color-danger-fg:#f85149}}@media (prefers-color-scheme:light){.markdown-body{color-scheme:light;--color-prettylights-syntax-comment:#6e7781;--color-prettylights-syntax-constant:#0550ae;--color-prettylights-syntax-entity:#8250df;--color-prettylights-syntax-storage-modifier-import:#24292f;--color-prettylights-syntax-entity-tag:#116329;--color-prettylights-syntax-keyword:#cf222e;--color-prettylights-syntax-string:#0a3069;--color-prettylights-syntax-variable:#953800;--color-prettylights-syntax-brackethighlighter-unmatched:#82071e;--color-prettylights-syntax-invalid-illegal-text:#f6f8fa;--color-prettylights-syntax-invalid-illegal-bg:#82071e;--color-prettylights-syntax-carriage-return-text:#f6f8fa;--color-prettylights-syntax-carriage-return-bg:#cf222e;--color-prettylights-syntax-string-regexp:#116329;--color-prettylights-syntax-markup-list:#3b2300;--color-prettylights-syntax-markup-heading:#0550ae;--color-prettylights-syntax-markup-italic:#24292f;--color-prettylights-syntax-markup-bold:#24292f;--color-prettylights-syntax-markup-deleted-text:#82071e;--color-prettylights-syntax-markup-deleted-bg:#FFEBE9;--color-prettylights-syntax-markup-inserted-text:#116329;--color-prettylights-syntax-markup-inserted-bg:#dafbe1;--color-prettylights-syntax-markup-changed-text:#953800;--color-prettylights-syntax-markup-changed-bg:#ffd8b5;--color-prettylights-syntax-markup-ignored-text:#eaeef2;--color-prettylights-syntax-markup-ignored-bg:#0550ae;--color-prettylights-syntax-meta-diff-range:#8250df;--color-prettylights-syntax-brackethighlighter-angle:#57606a;--color-prettylights-syntax-sublimelinter-gutter-mark:#8c959f;--color-prettylights-syntax-constant-other-reference-link:#0a3069;--color-fg-default:#24292f;--color-fg-muted:#57606a;--color-fg-subtle:#6e7781;--color-canvas-default:#ffffff;--color-canvas-subtle:#f6f8fa;--color-border-default:#d0d7de;--color-border-muted:hsla(210,18%,87%,1);--color-neutral-muted:rgba(175,184,193,0.2);--color-accent-fg:#0969da;--color-accent-emphasis:#0969da;--color-attention-subtle:#fff8c5;--color-danger-fg:#cf222e}}.markdown-body{-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%;margin:0;color:var(--color-fg-default);background-color:var(--color-canvas-default);font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji";font-size:16px;line-height:1.5;word-wrap:break-word}.markdown-body h1:hover .anchor .octicon-link:before,.markdown-body h2:hover .anchor .octicon-link:before,.markdown-body h3:hover .anchor .octicon-link:before,.markdown-body h4:hover .anchor .octicon-link:before,.markdown-body h5:hover .anchor .octicon-link:before,.markdown-body h6:hover .anchor .octicon-link:before{width:16px;height:16px;content:' ';display:inline-block;background-color:currentColor;-webkit-mask-image:url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' version='1.1' aria-hidden='true'><path fill-rule='evenodd' d='M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z'></path></svg>");mask-image:url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' version='1.1' aria-hidden='true'><path fill-rule='evenodd' d='M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z'></path></svg>")}.markdown-body [data-catalyst],.markdown-body details,.markdown-body figcaption,.markdown-body figure{display:block}.markdown-body summary{display:list-item}.markdown-body [hidden],.markdown-body details:not([open])>:not(summary){display:none!important}.markdown-body a{background-color:transparent;color:var(--color-accent-fg);text-decoration:none}.markdown-body a:active,.markdown-body a:hover{outline-width:0}.markdown-body abbr[title]{border-bottom:none;text-decoration:underline dotted}.markdown-body .pl-corl,.markdown-body a:hover{text-decoration:underline}.markdown-body b,.markdown-body strong,.markdown-body table th{font-weight:600}.markdown-body dfn{font-style:italic}.markdown-body h1{margin:.67em 0;padding-bottom:.3em;font-size:2em;border-bottom:1px solid var(--color-border-muted)}.markdown-body mark{background-color:var(--color-attention-subtle);color:var(--color-text-primary)}.markdown-body img,.markdown-body table tr{background-color:var(--color-canvas-default)}.markdown-body small{font-size:90%}.markdown-body sub,.markdown-body sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}.markdown-body sub{bottom:-.25em}.markdown-body sup{top:-.5em}.markdown-body img{border-style:none;max-width:100%;box-sizing:content-box}.markdown-body code,.markdown-body kbd,.markdown-body pre,.markdown-body samp{font-family:monospace,monospace;font-size:1em}.markdown-body figure{margin:1em 40px}.markdown-body hr{box-sizing:content-box;overflow:hidden;background:0 0;border-bottom:1px solid var(--color-border-muted);height:.25em;padding:0;margin:24px 0;background-color:var(--color-border-default);border:0}.markdown-body kbd,.markdown-body table tr:nth-child(2n){background-color:var(--color-canvas-subtle)}.markdown-body input{font:inherit;margin:0;overflow:visible;font-family:inherit;font-size:inherit;line-height:inherit}.markdown-body [type=button],.markdown-body [type=reset],.markdown-body [type=submit]{-webkit-appearance:button}.markdown-body [type=button]::-moz-focus-inner,.markdown-body [type=reset]::-moz-focus-inner,.markdown-body [type=submit]::-moz-focus-inner{border-style:none;padding:0}.markdown-body [type=button]:-moz-focusring,.markdown-body [type=reset]:-moz-focusring,.markdown-body [type=submit]:-moz-focusring{outline:ButtonText dotted 1px}.markdown-body [type=checkbox],.markdown-body [type=radio]{box-sizing:border-box;padding:0}.markdown-body [type=number]::-webkit-inner-spin-button,.markdown-body [type=number]::-webkit-outer-spin-button{height:auto}.markdown-body [type=search]{-webkit-appearance:textfield;outline-offset:-2px}.markdown-body [type=search]::-webkit-search-cancel-button,.markdown-body [type=search]::-webkit-search-decoration{-webkit-appearance:none}.markdown-body ::-webkit-input-placeholder{color:inherit;opacity:.54}.markdown-body ::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}.markdown-body hr::before,.markdown-body::before{display:table;content:""}.markdown-body hr::after,.markdown-body::after{display:table;clear:both;content:""}.markdown-body table{border-spacing:0;border-collapse:collapse;display:block;width:max-content;max-width:100%;overflow:auto}.markdown-body dl,.markdown-body td,.markdown-body th{padding:0}.markdown-body .task-list-item.enabled label,.markdown-body details summary{cursor:pointer}.markdown-body kbd{display:inline-block;padding:3px 5px;font:11px/10px ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,Liberation Mono,monospace;color:var(--color-fg-default);vertical-align:middle;border:solid 1px var(--color-neutral-muted);border-bottom-color:var(--color-neutral-muted);border-radius:6px;box-shadow:inset 0 -1px 0 var(--color-neutral-muted)}.markdown-body code,.markdown-body pre,.markdown-body tt{font-family:ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,Liberation Mono,monospace}.markdown-body h1,.markdown-body h2,.markdown-body h3,.markdown-body h4,.markdown-body h5,.markdown-body h6{margin-top:24px;margin-bottom:16px;font-weight:600;line-height:1.25}.markdown-body h2{font-weight:600;padding-bottom:.3em;font-size:1.5em;border-bottom:1px solid var(--color-border-muted)}.markdown-body h3{font-weight:600;font-size:1.25em}.markdown-body h4{font-weight:600;font-size:1em}.markdown-body h5{font-weight:600;font-size:.875em}.markdown-body h6{font-weight:600;font-size:.85em;color:var(--color-fg-muted)}.markdown-body blockquote{margin:0;padding:0 1em;color:var(--color-fg-muted);border-left:.25em solid var(--color-border-default)}.markdown-body ol,.markdown-body ul{padding-left:2em}.markdown-body ol ol,.markdown-body ol[type=i],.markdown-body ul ol{list-style-type:lower-roman}.markdown-body ol ol ol,.markdown-body ol ul ol,.markdown-body ol[type=a],.markdown-body ul ol ol,.markdown-body ul ul ol{list-style-type:lower-alpha}.markdown-body dd{margin-left:0}.markdown-body pre{word-wrap:normal}.markdown-body .octicon{fill:currentColor;display:inline-block;overflow:visible!important;vertical-align:text-bottom;fill:currentColor}.markdown-body ::placeholder{color:var(--color-fg-subtle);opacity:1}.markdown-body input::-webkit-inner-spin-button,.markdown-body input::-webkit-outer-spin-button{margin:0;-webkit-appearance:none;appearance:none}.markdown-body .pl-c{color:var(--color-prettylights-syntax-comment)}.markdown-body .pl-c1,.markdown-body .pl-s .pl-v{color:var(--color-prettylights-syntax-constant)}.markdown-body .pl-e,.markdown-body .pl-en{color:var(--color-prettylights-syntax-entity)}.markdown-body .pl-s .pl-s1,.markdown-body .pl-smi{color:var(--color-prettylights-syntax-storage-modifier-import)}.markdown-body .pl-ent{color:var(--color-prettylights-syntax-entity-tag)}.markdown-body .pl-k{color:var(--color-prettylights-syntax-keyword)}.markdown-body .pl-pds,.markdown-body .pl-s,.markdown-body .pl-s .pl-pse .pl-s1,.markdown-body .pl-sr,.markdown-body .pl-sr .pl-cce,.markdown-body .pl-sr .pl-sra,.markdown-body .pl-sr .pl-sre{color:var(--color-prettylights-syntax-string)}.markdown-body .pl-smw,.markdown-body .pl-v{color:var(--color-prettylights-syntax-variable)}.markdown-body .pl-bu{color:var(--color-prettylights-syntax-brackethighlighter-unmatched)}.markdown-body .pl-ii{color:var(--color-prettylights-syntax-invalid-illegal-text);background-color:var(--color-prettylights-syntax-invalid-illegal-bg)}.markdown-body .pl-c2{color:var(--color-prettylights-syntax-carriage-return-text);background-color:var(--color-prettylights-syntax-carriage-return-bg)}.markdown-body .pl-sr .pl-cce{font-weight:700;color:var(--color-prettylights-syntax-string-regexp)}.markdown-body .pl-ml{color:var(--color-prettylights-syntax-markup-list)}.markdown-body .pl-mh,.markdown-body .pl-mh .pl-en,.markdown-body .pl-ms{font-weight:700;color:var(--color-prettylights-syntax-markup-heading)}.markdown-body .pl-mi{font-style:italic;color:var(--color-prettylights-syntax-markup-italic)}.markdown-body .pl-mb{font-weight:700;color:var(--color-prettylights-syntax-markup-bold)}.markdown-body .pl-md{color:var(--color-prettylights-syntax-markup-deleted-text);background-color:var(--color-prettylights-syntax-markup-deleted-bg)}.markdown-body .pl-mi1{color:var(--color-prettylights-syntax-markup-inserted-text);background-color:var(--color-prettylights-syntax-markup-inserted-bg)}.markdown-body .pl-mc{color:var(--color-prettylights-syntax-markup-changed-text);background-color:var(--color-prettylights-syntax-markup-changed-bg)}.markdown-body .pl-mi2{color:var(--color-prettylights-syntax-markup-ignored-text);background-color:var(--color-prettylights-syntax-markup-ignored-bg)}.markdown-body .pl-mdr{font-weight:700;color:var(--color-prettylights-syntax-meta-diff-range)}.markdown-body .pl-ba{color:var(--color-prettylights-syntax-brackethighlighter-angle)}.markdown-body .pl-sg{color:var(--color-prettylights-syntax-sublimelinter-gutter-mark)}.markdown-body .pl-corl{color:var(--color-prettylights-syntax-constant-other-reference-link)}.markdown-body g-emoji{font-family:"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";font-size:1em;font-style:normal!important;font-weight:400;line-height:1;vertical-align:-.075em}.markdown-body g-emoji img{width:1em;height:1em}.markdown-body>:first-child{margin-top:0!important}.markdown-body>:last-child{margin-bottom:0!important}.markdown-body a:not([href]){color:inherit;text-decoration:none}.markdown-body .absent{color:var(--color-danger-fg)}.markdown-body .anchor{float:left;padding-right:4px;margin-left:-20px;line-height:1}.markdown-body .anchor:focus{outline:0}.markdown-body blockquote,.markdown-body details,.markdown-body dl,.markdown-body ol,.markdown-body p,.markdown-body pre,.markdown-body table,.markdown-body ul{margin-top:0;margin-bottom:16px}.markdown-body blockquote>:first-child{margin-top:0}.markdown-body blockquote>:last-child{margin-bottom:0}.markdown-body sup>a::before{content:"["}.markdown-body sup>a::after{content:"]"}.markdown-body h1 .octicon-link,.markdown-body h2 .octicon-link,.markdown-body h3 .octicon-link,.markdown-body h4 .octicon-link,.markdown-body h5 .octicon-link,.markdown-body h6 .octicon-link{color:var(--color-fg-default);vertical-align:middle;visibility:hidden}.markdown-body h1:hover .anchor,.markdown-body h2:hover .anchor,.markdown-body h3:hover .anchor,.markdown-body h4:hover .anchor,.markdown-body h5:hover .anchor,.markdown-body h6:hover .anchor{text-decoration:none}.markdown-body h1:hover .anchor .octicon-link,.markdown-body h2:hover .anchor .octicon-link,.markdown-body h3:hover .anchor .octicon-link,.markdown-body h4:hover .anchor .octicon-link,.markdown-body h5:hover .anchor .octicon-link,.markdown-body h6:hover .anchor .octicon-link{visibility:visible}.markdown-body h1 code,.markdown-body h1 tt,.markdown-body h2 code,.markdown-body h2 tt,.markdown-body h3 code,.markdown-body h3 tt,.markdown-body h4 code,.markdown-body h4 tt,.markdown-body h5 code,.markdown-body h5 tt,.markdown-body h6 code,.markdown-body h6 tt{padding:0 .2em;font-size:inherit}.markdown-body ol.no-list,.markdown-body ul.no-list{padding:0;list-style-type:none}.markdown-body div>ol:not([type]),.markdown-body ol[type="1"]{list-style-type:decimal}.markdown-body ol ol,.markdown-body ol ul,.markdown-body ul ol,.markdown-body ul ul{margin-top:0;margin-bottom:0}.markdown-body li>p{margin-top:16px}.markdown-body li+li{margin-top:.25em}.markdown-body dl dt{padding:0;margin-top:16px;font-size:1em;font-style:italic;font-weight:600}.markdown-body dl dd{padding:0 16px;margin-bottom:16px}.markdown-body table td,.markdown-body table th{padding:6px 13px;border:1px solid var(--color-border-default)}.markdown-body table tr{border-top:1px solid var(--color-border-muted)}.markdown-body .emoji,.markdown-body table img{background-color:transparent}.markdown-body img[align=right]{padding-left:20px}.markdown-body img[align=left]{padding-right:20px}.markdown-body .emoji{max-width:none;vertical-align:text-top}.markdown-body span.frame{display:block;overflow:hidden}.markdown-body span.frame>span{display:block;float:left;width:auto;padding:7px;margin:13px 0 0;overflow:hidden;border:1px solid var(--color-border-default)}.markdown-body span.frame span img{display:block;float:left}.markdown-body span.frame span span{display:block;padding:5px 0 0;clear:both;color:var(--color-fg-default)}.markdown-body span.align-center,.markdown-body span.align-right{display:block;overflow:hidden;clear:both}.markdown-body span.align-center>span{display:block;margin:13px auto 0;overflow:hidden;text-align:center}.markdown-body span.align-center span img{margin:0 auto;text-align:center}.markdown-body span.align-right>span{display:block;margin:13px 0 0;overflow:hidden;text-align:right}.markdown-body span.align-right span img{margin:0;text-align:right}.markdown-body span.float-left{display:block;float:left;margin-right:13px;overflow:hidden}.markdown-body span.float-left span{margin:13px 0 0}.markdown-body span.float-right{display:block;float:right;margin-left:13px;overflow:hidden}.markdown-body span.float-right>span{display:block;margin:13px auto 0;overflow:hidden;text-align:right}.markdown-body code,.markdown-body tt{padding:.2em .4em;margin:0;font-size:85%;background-color:var(--color-neutral-muted);border-radius:6px}.markdown-body .task-list-item .handle,.markdown-body code br,.markdown-body tt br{display:none}.markdown-body del code{text-decoration:inherit}.markdown-body pre code{font-size:100%}.markdown-body pre>code{padding:0;margin:0;word-break:normal;white-space:pre;background:0 0;border:0}.markdown-body .highlight{margin-bottom:16px}.markdown-body .highlight pre{margin-bottom:0;word-break:normal}.markdown-body .highlight pre,.markdown-body pre{padding:16px;overflow:auto;font-size:85%;line-height:1.45;background-color:var(--color-canvas-subtle);border-radius:6px}.markdown-body pre code,.markdown-body pre tt{display:inline;max-width:auto;padding:0;margin:0;overflow:visible;line-height:inherit;word-wrap:normal;background-color:transparent;border:0}.markdown-body .csv-data td,.markdown-body .csv-data th{padding:5px;overflow:hidden;font-size:12px;line-height:1;text-align:left;white-space:nowrap}.markdown-body .csv-data .blob-num{padding:10px 8px 9px;text-align:right;background:var(--color-canvas-default);border:0}.markdown-body .csv-data tr{border-top:0}.markdown-body .csv-data th{font-weight:600;background:var(--color-canvas-subtle);border-top:0}.markdown-body .footnotes{font-size:12px;color:var(--color-fg-muted);border-top:1px solid var(--color-border-default)}.markdown-body .footnotes ol{padding-left:16px}.markdown-body .footnotes li{position:relative}.markdown-body .footnotes li:target::before{position:absolute;top:-8px;right:-8px;bottom:-8px;left:-24px;pointer-events:none;content:"";border:2px solid var(--color-accent-emphasis);border-radius:6px}.markdown-body .footnotes li:target{color:var(--color-fg-default)}.markdown-body .footnotes .data-footnote-backref g-emoji{font-family:monospace}.markdown-body .task-list-item{list-style-type:none}.markdown-body .task-list-item label{font-weight:400}.markdown-body .task-list-item+.task-list-item{margin-top:3px}.markdown-body .task-list-item-checkbox{margin:0 .2em .25em -1.6em;vertical-align:middle}.markdown-body .contains-task-list:dir(rtl) .task-list-item-checkbox{margin:0 -1.6em .25em .2em}.markdown-body ::-webkit-calendar-picker-indicator{filter:invert(50%)}
    </style>
  """;
}
