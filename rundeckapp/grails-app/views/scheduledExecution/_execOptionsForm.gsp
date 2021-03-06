%{--
  - Copyright 2016 SimplifyOps, Inc. (http://simplifyops.com)
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  --}%
<%@ page import="rundeck.User;" %>


<g:uploadForm controller="scheduledExecution" method="post" useToken="true"
              params="[project: scheduledExecution.project]" role="form" >
<div id="exec_options_form">
    <!-- BEGIN: firefox hack https://bugzilla.mozilla.org/show_bug.cgi?id=1119063 -->
    <input type="text" style="display:none" class="ixnay">
    <input type="password" style="display:none" class="ixnay">
    <g:javascript>
    jQuery(function(){
        var nay=function(){jQuery('.ixnay').val('');},ix=setTimeout;
        nay(); ix(nay,50); ix(nay,200); ix(nay, 1000);
    });
    </g:javascript>
    <!-- END: firefox hack -->
<div class="exec-options-body container-fluid">



<g:if test="${!hideHead}">
    <div class="row exec-options-header">
        <div class="col-sm-12">
            <tmpl:showHead scheduledExecution="${scheduledExecution}" iconName="icon-job"
                           runPage="true" jobDescriptionMode="collapsed"/>
        </div>
    </div>

</g:if>
    <g:set var="project" value="${scheduledExecution?.project ?: params.project?:request.project?: projects?.size() == 1 ? projects[0].name : ''}"/>
    <g:embedJSON id="filterParamsJSON" data="${[filterName: params.filterName, filter: query?.filter, filterAll: params.showall in ['true', true]]}"/>
    <div class=" collapse" id="queryFilterHelp">
        <div class="help-block">
            <g:render template="/common/nodefilterStringHelp"/>
        </div>
    </div>
<div>
<div>
<div class="row">
    <div class="col-xs-12 form-horizontal">

    <g:render template="editOptions" model="${[scheduledExecution:scheduledExecution, selectedoptsmap:selectedoptsmap, selectedargstring:selectedargstring,authorized:authorized,jobexecOptionErrors:jobexecOptionErrors, optiondependencies: optiondependencies, dependentoptions: dependentoptions, optionordering: optionordering]}"/>
    <div class="form-group" style="${wdgt.styleVisible(if: nodesetvariables && !failedNodes || nodesetempty || nodes)}">
    <div class="col-sm-2 control-label text-form-label">
        <g:message code="Node.plural" />
    </div>


    <div class="col-sm-10">
        <g:if test="${nodesetvariables && !failedNodes}">
            %{--show node filters--}%
            <div>
                <span class="query form-control-static ">
                   <span class="queryvalue text"><g:enc>${nodefilter}</g:enc></span>
                </span>
            </div>

            <p class="form-control-static text-info">
                <g:message code="scheduledExecution.nodeset.variable.warning"/>
            </p>
        </g:if>
        <g:elseif test="${nodesetempty }">
            <div class="alert alert-warning">
                <g:message code="scheduledExecution.nodeset.empty.warning"/>
            </div>
        </g:elseif>


            <g:set var="selectedNodes"
                   value="${failedNodes? failedNodes.split(',').findAll{it}:selectedNodes instanceof String? selectedNodes.split(',').findAll{it}:selectedNodes instanceof Collection? selectedNodes:null}"/>

            <div class="row">
                <div class="col-sm-12 checkbox">
                    <input name="extra._replaceNodeFilters" value="true" type="checkbox"
                           data-toggle="collapse"
                           data-target="#nodeSelect"
                        ${selectedNodes!=null?'checked':''}
                           id="doReplaceFilters"/>
                    <label for="doReplaceFilters">
                    <g:message code="change.the.target.nodes" />
                    <g:if test="${selectedNodes || nodes}">
                        (<span class="nodeselectcount"><g:enc>${selectedNodes!=null?selectedNodes.size():nodes.size()}</g:enc></span>)
                    </g:if>
                    </label>
                </div>

            </div>
            <div>
              <div class=" matchednodes embed jobmatchednodes group_section collapse ${selectedNodes!=null? 'in' : ''}" id="nodeSelect">
                <%--
                 split node names into groups, in several patterns
                  .*\D(\d+)
                  (\d+)\D.*
                --%>


                <g:if test="${!nodesetvariables && nodes}">
                    <div class=" group_select_control">
                        <div class="radio">
                            <input id="cherrypickradio"
                                   type="radio"
                                   name="extra.nodeoverride"
                                   checked="checked"
                                   value="cherrypick"
                            />
                            <label for="cherrypickradio">
                                <g:message code="select.prompt" /> (<span class="nodeselectcount"><g:enc>${selectedNodes!=null?selectedNodes.size():nodes.size()}</g:enc></span>)
                            </label>
                            <span class="btn btn-xs btn-default textbtn-on-hover selectall"><g:message code="all" /></span>
                            <span class="btn btn-xs btn-default textbtn-on-hover selectnone"><g:message code="none" /></span>
                        </div>
                        <g:if test="${tagsummary}">
                            <g:render template="/framework/tagsummary"
                                      model="${[tagsummary:tagsummary,action:[classnames:'label label-muted obs_tag_group',onclick:'']]}"/>
                        </g:if>
                    </div>
                <g:if test="${namegroups}">

                    <g:each in="${namegroups.keySet().sort()}" var="group">
                        <div class="panel panel-default">
                      <div class="panel-heading">
                          <g:set var="expkey" value="${g.rkey()}"/>
                            <span data-toggle="collapse" data-target="#${expkey}" open="${selectedNodes!=null?'true':'false'}">
                                <g:if test="${group!='other'}">
                                    <span class="prompt">
                                    <g:enc>${namegroups[group][0]}</g:enc></span>
                                    <g:message code="to"/>
                                    <span class="prompt">
                                <g:enc>${namegroups[group][-1]}</g:enc>
                                    </span>
                                </g:if>
                                <g:else>
                                    <span class="prompt"><g:enc>${namegroups.size()>1?'Other ':''}</g:enc><g:message code="matched.nodes.prompt" /></span>
                                </g:else>
                                <g:enc>(${namegroups[group].size()})</g:enc>
                                <b class="glyphicon glyphicon-chevron-${selectedNodes!=null ? 'down' : 'right'}"></b>
                            </span>
                        </div>
                        <div id="${enc(attr:expkey)}"  class="group_section panel-body collapse ${wdgt.css(if: selectedNodes!=null, then:'in')}">
                                <g:if test="${namegroups.size()>1}">
                                <div class="group_select_control" style="${selectedNodes!=null?'':'display:none'}">
                                    <g:message code="select.prompt" />
                                    <span class="btn btn-xs btn-default textbtn-on-hover selectall" ><g:message code="all" /></span>
                                    <span class="btn btn-xs btn-default textbtn-on-hover selectnone" ><g:message code="none" /></span>
                                    <g:if test="${grouptags && grouptags[group]}">
                                        <g:render template="/framework/tagsummary" model="${[tagsummary:grouptags[group],action:[classnames:'tag active btn btn-xs btn-link  obs_tag_group',onclick:'']]}"/>
                                    </g:if>
                                </div>
                                </g:if>
                                    <g:each var="node" in="${nodemap.subMap(namegroups[group]).values()}" status="index">
                                        <g:set var="nkey" value="${g.rkey()}"/>
                                        <div class="checkbox node_select_checkbox" >
                                          <input id="${enc(attr:nkey)}"
                                                 type="checkbox"
                                                 data-ident="node"
                                                 name="extra.nodeIncludeName"
                                                 value="${enc(attr:node.nodename)}"
                                                 ${selectedNodes!=null ? '':'disabled' }
                                                 data-tag="${enc(attr:node.tags?.join(' '))}"
                                                  ${(null== selectedNodes||selectedNodes.contains(node.nodename))?'checked':''}
                                                 />
                                            <label for="${enc(attr:nkey)}"
                                                   class=" ${localNodeName && localNodeName == node.nodename ? 'server' : ''} node_ident"
                                                   id="${enc(attr:nkey)}_key">


                                                    <g:nodeIconStatusColor node="${node}" icon="true">
                                                        <g:nodeIcon node="${node}">
                                                            <i class="fas fa-hdd"></i>
                                                        </g:nodeIcon>
                                                    </g:nodeIconStatusColor>&nbsp;<span class="${unselectedNodes&& unselectedNodes.contains(node.nodename)?'node_unselected':''}"><g:enc>${node.nodename}</g:enc></span>
                                                    <g:nodeHealthStatusColor node="${node}" title="${node.attributes['ui:status:text']}">
                                                        <g:nodeStatusIcon node="${node}"/>
                                                    </g:nodeHealthStatusColor>

                                                 </label>

                                        </div>
                                    </g:each>
                            </div>
                        </div>
                    </g:each>

                </g:if>
                <g:else>
                    <g:each var="node" in="${nodes}" status="index">
                        <g:set var="nkey" value="${g.rkey()}"/>
                        <div>
                            <label for="${enc(attr:nkey)}"
                                   class=" ${localNodeName && localNodeName == node.nodename ? 'server' : ''} node_ident  checkbox-inline"
                                   id="${enc(attr:nkey)}_key">
                                <input id="${enc(attr:nkey)}"
                                       type="checkbox"
                                       name="extra.nodeIncludeName"
                                       data-ident="node"
                                       value="${enc(attr:node.nodename)}"
                                       disabled="true"
                                       data-tag="${enc(attr:node.tags?.join(' '))}"
                                       checked="true"/><g:enc>${node.nodename}</g:enc></label>

                        </div>
                    </g:each>
                </g:else>
                </g:if>
                <g:if test="${scheduledExecution.nodeFilterEditable || nodefilter == ''}">
                <div class="subfields nodeFilterFields ">
                    %{-- filter text --}%
                    <div class="">
                        <g:set var="filtvalue" value="${nodefilter}"/>
                    <div class="radio">
                        <input id="filterradio"
                               type="radio"
                               name="extra.nodeoverride"
                            ${(!nodesetvariables && nodes)?'':'checked=true'}
                               value="filter"
                        />
                        <label for="filterradio" >
                            <span>
                        <g:if test="${!nodesetvariables && nodes}"><g:message code="or"/> </g:if>
                                <g:message code="job.run.override.node"/>: </span>

                        </label>
                    </div>
                    <g:if test="${session.user && User.findByLogin(session.user)?.nodefilters}">
                        <g:set var="filterset" value="${User.findByLogin(session.user)?.nodefilters.findAll{it.project == project}}"/>
                    </g:if>

                    <div id="nodefilterViewArea" data-ko-bind="nodeFilter">
                        <div class="${emptyQuery ? 'active' : ''}" id="nodeFilterInline">
                            <div class="spacing">
                                <div class="">
                                    <g:form action="adhoc" class="form form-horizontal" name="searchForm" >
                                        <g:hiddenField name="max" value="${max}"/>
                                        <g:hiddenField name="offset" value="${offset}"/>
                                        <g:hiddenField name="formInput" value="true"/>

                                        <div>
                                            <span class=" input-group multiple-control-input-group" >
                                                <g:render template="/framework/nodeFilterInputGroup"
                                                          model="[filterFieldName: 'extra.nodefilter',filterset: filterset, filtvalue: filtvalue, filterName: filterName]"/>
                                            </span>
                                        </div>
                                    </g:form>

                                    <div class=" collapse" id="queryFilterHelp">
                                        <div class="help-block">
                                            <g:render template="/common/nodefilterStringHelp"/>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <div>
                                <div class="spacing text-warning" id="emptyerror"
                                     style="display: none"
                                     data-bind="visible: !loading() && !error() && (!total() || total()==0)">
                                    <span class="errormessage">
                                        <g:message code="no.nodes.selected.match.nodes.by.selecting.or.entering.a.filter" />
                                    </span>
                                </div>
                                <div class="spacing text-danger" id="loaderror2"
                                     style="display: none"
                                     data-bind="visible: error()">
                                    <i class="glyphicon glyphicon-warning-sign"></i>
                                    <span class="errormessage" data-bind="text: error()">

                                    </span>
                                </div>
                                <div data-bind="visible: total()>0 || loading()" class="well well-sm inline">
                                    <span data-bind="if: loading()" class="text-info">
                                        <i class="glyphicon glyphicon-time"></i>
                                        <g:message code="loading.matched.nodes" />
                                    </span>
                                    <span data-bind="if: !loading() && !error()">

                                        <span data-bind="messageTemplate: [ total(), nodesTitle() ]"><g:message code="count.nodes.matched" /></span>.

                                        <span data-bind="if: total()>maxShown()">
                                            <span data-bind="messageTemplate: [maxShown(), total()]" class="text-primary"><g:message code="count.nodes.shown" /></span>
                                        </span>
                                        <div class="pull-right">
                                          <a class="btn btn-default btn-sm" data-bind="click: nodesPageView">
                                              <g:message code="view.in.nodes.page.prompt" />
                                          </a>
                                        </div>

                                    </span>
                                </div>
                                <span >
                                    <g:render template="/framework/nodesEmbedKO"/>
                                </span>
                        </div>
                    </div>



                        %{-- filter text --}%
                    </div>


                </div>
                    </g:if>
            </div>
            </div>
            <g:javascript>
                var updateSelectCount = function (evt) {
                    var count = 0;
                    jQuery('[data-ident="node"]').each(function (i,e2) {
                        if (e2.checked) {
                            count++;
                        }
                    });
                    jQuery('.nodeselectcount').each(function (i,e2) {
                        jQuery(e2).text( count + '');
                        jQuery(e2).removeClass('text-info');
                        jQuery(e2).removeClass('text-danger');
                        jQuery(e2).addClass(count>0?'text-info':'text-danger');
                    });
                };
                jQuery('[data-ident="node"]').each(function (i,e) {
                    jQuery(e).on('change', function (evt) {
                      jQuery('#nodeSelect').trigger( 'nodeset:change');
                    });
                });
                jQuery('#nodeSelect').on( 'nodeset:change', updateSelectCount);
                jQuery('div.jobmatchednodes span.selectall').each(function (i,e) {
                    jQuery(e).on( 'click', function (evt) {
                        jQuery(e).closest('.group_section').find('input').each(function (i,el) {
                            if (el.type == 'checkbox') {
                                el.checked = true;
                            }
                        });
                        jQuery(e).closest('.group_section').find('span.obs_tag_group').each(function (i,e) {
                            jQuery(e).attr('data-tagselected', 'true');
                            jQuery(e).addClass('active');
                        });
                        jQuery('#nodeSelect').trigger( 'nodeset:change');
                    });
                });
                jQuery('div.jobmatchednodes span.selectnone').each(function (i,e) {
                    jQuery(e).on( 'click', function (evt) {
                        jQuery(e).closest('.group_section').find('input').each(function (i,el) {
                            if (el.type == 'checkbox') {
                                el.checked = false;
                            }
                        });
                        jQuery(e).closest('.group_section').find('span.obs_tag_group').each(function (i,e) {
                            jQuery(e).attr('data-tagselected', 'false');
                            jQuery(e).removeClass('active');
                        });
                        jQuery('#nodeSelect').trigger( 'nodeset:change');
                    });
                });
                jQuery('div.jobmatchednodes span.obs_tag_group').each(function (i,e) {
                    jQuery(e).on( 'click', function (evt) {
                        var ischecked = e.getAttribute('data-tagselected') != 'false';
                        e.setAttribute('data-tagselected', ischecked ? 'false' : 'true');
                        if (!ischecked) {
                            jQuery(e).addClass('active');
                        } else {
                            jQuery(e).removeClass('active');
                        }
                        jQuery(e).closest('.group_section').find('input[data-tag~="' + e.getAttribute('data-tag') + '"]').each(function (i,el) {
                            if (el.type == 'checkbox') {
                                el.checked = !ischecked;
                            }
                        });
                        jQuery(e).closest('.group_section').find('span.obs_tag_group[data-tag="' + e.getAttribute('data-tag') + '"]').each(function (i,el) {
                            el.setAttribute('data-tagselected', ischecked ? 'false' : 'true');
                            if (!ischecked) {
                                jQuery(el).addClass('active');
                            } else {
                                jQuery(el).removeClass('active');
                            }
                        });
                        jQuery('#nodeSelect').trigger( 'nodeset:change');
                    });
                });

                jQuery('#doReplaceFilters').on( 'change', function (evt) {
                    var e = evt.target
                    jQuery('div.jobmatchednodes input').each(function (i,cb) {
                        if (cb.type == 'checkbox') {
                            jQuery(cb).prop('disabled',!e.checked)
                            if (!e.checked) {
                                jQuery('.group_select_control').hide();
                                cb.checked = true;
                            } else {
                                jQuery('.group_select_control').show();
                            }
                        }
                    });
                    jQuery('#nodeSelect').trigger( 'nodeset:change');
                    if(!e.checked){
                        jQuery('.nodeselectcount').each(function (i,e2) {
                            jQuery(e2).removeClass('text-info');
                            jQuery(e2).removeClass('text-danger');
                        });
                    }
                });


                /** reset focus on click, so that IE triggers onchange event*/
                jQuery('#doReplaceFilters').on( 'click', function (evt) {
                    this.blur();
                    this.focus();
                });

            </g:javascript>
            <g:if test="${scheduledExecution.hasNodesSelectedByDefault()}">
                <g:javascript>
                    jQuery('#nodeSelect').trigger( 'nodeset:change');
                </g:javascript>
            </g:if>

    </div>
    </div>

    <div class="error note" id="formerror" style="display:none">

    </div>
</div>
<g:if test="${hideHead}">
<div class="col-xs-12">
    <g:render template="/scheduledExecution/execOptionsFormButtons" model="[scheduledExecution:scheduledExecution,hideCancel:hideCancel,showRunLater:true]"/>
</div>
</g:if>
</div>
</div>
</div>
</div>

<g:if test="${!hideHead}">
<div class=" exec-options-footer container-fluid">
    <div class="row" >
        <div class="col-sm-12 form-inline">
            <g:render template="/scheduledExecution/execOptionsFormButtons" model="[scheduledExecution:scheduledExecution,hideCancel:hideCancel]"/>
        </div>
    </div>
</div>
</g:if>
</div>
</g:uploadForm>

<script lang="text/javascript">
    function init() {
        var pageParams = loadJsonData('pageParams');
        jQuery('body').on('click', '.nodefilterlink', function (evt) {
            evt.preventDefault();
            nodeFilter.selectNodeFilterLink(this);
            $('filterradio').checked=true;
        });
        jQuery('#nodesContent').on('click', '.closeoutput', function (evt) {
            evt.preventDefault();
            closeOutputArea();
        });


        //setup node filters knockout bindings
        var filterParams = loadJsonData('filterParamsJSON');
        let kocontrollers={}

        <g:if test="${scheduledExecution.nodeFilterEditable || nodefilter == ''}">
        var nodeSummary = new NodeSummary({baseUrl:appLinks.frameworkNodes});
        var nodeFilter = new NodeFilters(
                appLinks.frameworkAdhoc,
                appLinks.scheduledExecutionCreate,
                appLinks.frameworkNodes,
                Object.assign(filterParams, {
                    nodeSummary:nodeSummary,
                    view: 'embed',
                    maxShown: 100,
                    emptyMode: 'blank',
                    project: pageParams.project,
                    nodesTitleSingular: message('Node'),
                    nodesTitlePlural: message('Node.plural')
                }));

            // ko.applyBindings(nodeFilter, document.getElementById('nodefilterViewArea'));
        //show selected named filter
        nodeFilter.filterName.subscribe(function (val) {
            if (val) {
                jQuery('a[data-node-filter-name]').removeClass('active');
                jQuery('a[data-node-filter-name=\'' + val + '\']').addClass('active');
            }
        });

        nodeSummary.reload();
        nodeFilter.updateMatchedNodes();

        var tmpfilt = {};
        jQuery.data( tmpfilt, "node-filter-name", "" );
        jQuery.data( tmpfilt, "node-filter", "${nodefilter}" );
        nodeFilter.selectNodeFilterLink(tmpfilt);

        kocontrollers.nodeFilter = nodeFilter

        </g:if>
        kocontrollers.runformoptions = new JobRunFormOptions({debug:${enc(js:scheduledExecution?.loglevel=='DEBUG')}})

        initKoBind('#exec_options_form', kocontrollers, /*'execform'*/)
    }
    jQuery(document).ready(init);
</script>
<content tag="footScripts">
    <asset:stylesheet src="library/bootstrap-datetimepicker.min.css" />
    <asset:javascript src="scheduler.js" />
</content tag="footScripts">

<asset:stylesheet src="library/bootstrap-datetimepicker.min.css" />
<asset:javascript src="scheduler.js" />
